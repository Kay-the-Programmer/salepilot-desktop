import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/product.dart';

const _uuid = Uuid();

class ProductsRepository {
  ProductsRepository({required this.api, required this.db});
  final ApiClient api;
  final AppDatabase db;

  Stream<List<Product>> watchActive() {
    return db.watchActiveProducts().map((rows) => rows.map(_toModel).toList());
  }

  /// All products incl. archived — for the inventory list + dashboard.
  Stream<List<Product>> watchAll() {
    return db.watchAllProducts().map((rows) => rows.map(_toModel).toList());
  }

  /// Local audit log of stock movements (newest first).
  Stream<List<StockMovementRow>> watchStockMovements({int limit = 100, String? productId}) {
    return db.watchStockMovements(limit: limit, productId: productId);
  }

  Future<List<Product>> listActive() async {
    final rows = await db.allActiveProducts();
    return rows.map(_toModel).toList();
  }

  Future<Product?> findByCode(String code) async {
    final row = await db.findProductByBarcodeOrSku(code);
    return row == null ? null : _toModel(row);
  }

  /// Pull full catalog from server, replace local cache.
  Future<int> pullFromServer() async {
    final res = await api.get('/products');
    final list = _extractList(res);
    final rows = list.map((j) {
      final p = Product.fromJson(Map<String, dynamic>.from(j as Map));
      return ProductsCompanion.insert(
        id: p.id,
        name: p.name,
        sku: p.sku,
        barcode: Value(p.barcode),
        categoryId: Value(p.categoryId),
        price: p.price,
        costPrice: Value(p.costPrice),
        stock: p.stock,
        status: Value(p.status),
        description: Value(p.description),
        unitOfMeasure: Value(p.unitOfMeasure),
        imageUrlsJson: Value(jsonEncode(p.imageUrls)),
        brand: Value(p.brand),
        reorderPoint: Value(p.reorderPoint),
        unitsPerBox: Value(p.unitsPerBox),
        boxCost: Value(p.boxCost),
        updatedAt: Value(p.updatedAt),
      );
    }).toList();
    await db.transaction(() async {
      await db.clearProducts();
      await db.upsertProducts(rows);
    });
    return rows.length;
  }

  /// Decrement local stock immediately after a sale; server reconciles later.
  Future<void> decrementLocalStock(Map<String, double> productIdToQty) async {
    if (productIdToQty.isEmpty) return;
    await db.transaction(() async {
      for (final entry in productIdToQty.entries) {
        await db.customUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          variables: [
            Variable.withReal(entry.value),
            Variable.withString(entry.key),
          ],
          updates: {db.products},
        );
      }
    });
  }

  /// Restock locally after a return where the cashier opted to add items back.
  Future<void> incrementLocalStock(Map<String, double> productIdToQty) async {
    if (productIdToQty.isEmpty) return;
    await db.transaction(() async {
      for (final entry in productIdToQty.entries) {
        await db.customUpdate(
          'UPDATE products SET stock = stock + ? WHERE id = ?',
          variables: [
            Variable.withReal(entry.value),
            Variable.withString(entry.key),
          ],
          updates: {db.products},
        );
      }
    });
  }

  // ───────────────────────── Mutations ─────────────────────────
  // All mutations are offline-first: write to local SQLite immediately, then
  // queue the server call (honored by SyncEngine via the queue's method).
  // Products with a `local-*` id only exist on the device until their create
  // syncs, so we skip server calls for them until a pull reconciles.

  bool _isServerSynced(String id) => !id.startsWith('local-');
  int get _now => DateTime.now().millisecondsSinceEpoch;

  /// Create a product. Online-first: a successful POST returns the canonical
  /// server row (real id). Offline/error: create a `local-*` row and queue the
  /// create so it lands on the server once connectivity returns.
  Future<Product> createProduct({
    required String name,
    required String sku,
    String? barcode,
    String? brand,
    required String categoryId,
    required double price,
    double? costPrice,
    double initialStock = 0,
    double? reorderPoint,
    String? description,
    String unitOfMeasure = 'unit',
    List<String> imagePaths = const [],
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'sku': sku,
      'barcode': ?barcode,
      'brand': ?brand,
      'categoryId': categoryId,
      'price': price,
      'costPrice': ?costPrice,
      'stock': initialStock,
      'reorderPoint': ?reorderPoint,
      'description': ?description,
      'unitOfMeasure': unitOfMeasure,
    };

    Product local(String id) => Product(
          id: id,
          name: name,
          sku: sku,
          barcode: barcode,
          categoryId: categoryId,
          price: price,
          costPrice: costPrice,
          stock: initialStock,
          status: 'active',
          description: description ?? '',
          unitOfMeasure: unitOfMeasure,
          imageUrls: imagePaths,
          brand: brand,
          reorderPoint: reorderPoint,
        );

    try {
      final res = await api.post('/products', body: body);
      final json = _firstObject(res);
      final created = json.isEmpty ? local('local-${_uuid.v4()}') : Product.fromJson(json);
      // Server-side JSON create can't carry the picked image files; keep the
      // local paths so the operator still sees their photos until next pull.
      final withImages = created.imageUrls.isEmpty && imagePaths.isNotEmpty
          ? created.copyWith(imageUrls: imagePaths)
          : created;
      await _upsertLocal(withImages);
      return withImages;
    } on ApiException {
      final product = local('local-${_uuid.v4()}');
      await _upsertLocal(product);
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products',
        method: const Value('POST'),
        bodyJson: jsonEncode(body),
        createdAt: _now,
      ));
      return product;
    }
  }

  /// Update an existing product. Local partial update + queued PUT.
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String sku,
    String? barcode,
    String? brand,
    required double price,
    double? costPrice,
    double? reorderPoint,
    required String description,
    required String unitOfMeasure,
    Value<String?> categoryId = const Value.absent(),
    Value<int?> unitsPerBox = const Value.absent(),
    Value<double?> boxCost = const Value.absent(),
  }) async {
    await db.updateProductRow(
      productId,
      ProductsCompanion(
        name: Value(name),
        sku: Value(sku),
        barcode: Value(barcode),
        brand: Value(brand),
        price: Value(price),
        costPrice: Value(costPrice),
        reorderPoint: Value(reorderPoint),
        description: Value(description),
        unitOfMeasure: Value(unitOfMeasure),
        categoryId: categoryId,
        unitsPerBox: unitsPerBox,
        boxCost: boxCost,
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
    if (_isServerSynced(productId)) {
      final body = <String, dynamic>{
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'brand': brand,
        'price': price,
        'costPrice': costPrice,
        'reorderPoint': reorderPoint,
        'description': description,
        'unitOfMeasure': unitOfMeasure,
        if (categoryId.present) 'categoryId': categoryId.value,
        if (unitsPerBox.present) 'unitsPerBox': unitsPerBox.value,
        if (boxCost.present) 'boxCost': boxCost.value,
      };
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products/$productId',
        method: const Value('PUT'),
        bodyJson: jsonEncode(body),
        createdAt: _now,
      ));
    }
  }

  /// Archive / restore a product (soft delete).
  Future<void> setArchived({required String productId, required bool archived}) async {
    final status = archived ? 'archived' : 'active';
    await db.updateProductRow(productId, ProductsCompanion(status: Value(status)));
    if (_isServerSynced(productId)) {
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products/$productId/archive',
        method: const Value('PATCH'),
        bodyJson: jsonEncode({'targetStatus': status}),
        createdAt: _now,
      ));
    }
  }

  /// Permanently delete a product.
  Future<void> deleteProduct(String productId) async {
    await db.deleteProductById(productId);
    if (_isServerSynced(productId)) {
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products/$productId',
        method: const Value('DELETE'),
        bodyJson: '',
        createdAt: _now,
      ));
    }
  }

  /// Set a product's stock to an absolute value, logging the movement.
  Future<void> adjustStock({
    required String productId,
    required double newAbsoluteStock,
    required String reason,
  }) async {
    final row = await db.productById(productId);
    final prev = row?.stock ?? 0;
    await db.updateProductRow(productId, ProductsCompanion(stock: Value(newAbsoluteStock)));
    await _logMovement(
      productId: productId,
      productName: row?.name ?? productId,
      previous: prev,
      next: newAbsoluteStock,
      reason: reason,
    );
    if (_isServerSynced(productId)) {
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products/$productId/stock',
        method: const Value('PATCH'),
        bodyJson: jsonEncode({'newQuantity': newAbsoluteStock, 'reason': reason}),
        createdAt: _now,
      ));
    }
  }

  /// Receive a shipment: add `boxesReceived * unitsPerBox` units, remember the
  /// box config for next time, and log the movement.
  Future<void> receiveShipment({
    required Product product,
    required int boxesReceived,
    required int unitsPerBox,
    double? boxCost,
    String? note,
  }) async {
    final added = (boxesReceived * unitsPerBox).toDouble();
    final newStock = product.stock + added;
    await db.updateProductRow(
      product.id,
      ProductsCompanion(
        stock: Value(newStock),
        unitsPerBox: Value(unitsPerBox),
        boxCost: boxCost != null ? Value(boxCost) : const Value.absent(),
      ),
    );
    await _logMovement(
      productId: product.id,
      productName: product.name,
      previous: product.stock,
      next: newStock,
      reason: (note == null || note.isEmpty) ? 'Received shipment' : 'Received: $note',
    );
    if (_isServerSynced(product.id)) {
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/products/${product.id}/stock',
        method: const Value('PATCH'),
        bodyJson: jsonEncode({'newQuantity': newStock, 'reason': 'Received shipment'}),
        createdAt: _now,
      ));
    }
  }

  Future<void> _logMovement({
    required String productId,
    required String productName,
    required double previous,
    required double next,
    required String reason,
  }) async {
    await db.insertStockMovement(StockMovementsCompanion.insert(
      productId: productId,
      productName: productName,
      delta: next - previous,
      previousStock: previous,
      newStock: next,
      reason: reason,
      createdAt: _now,
      synced: const Value(1),
    ));
  }

  Future<void> _upsertLocal(Product p) => db.upsertProducts([
        ProductsCompanion.insert(
          id: p.id,
          name: p.name,
          sku: p.sku,
          barcode: Value(p.barcode),
          categoryId: Value(p.categoryId),
          price: p.price,
          costPrice: Value(p.costPrice),
          stock: p.stock,
          status: Value(p.status),
          description: Value(p.description),
          unitOfMeasure: Value(p.unitOfMeasure),
          imageUrlsJson: Value(jsonEncode(p.imageUrls)),
          brand: Value(p.brand),
          reorderPoint: Value(p.reorderPoint),
          unitsPerBox: Value(p.unitsPerBox),
          boxCost: Value(p.boxCost),
          updatedAt: Value(p.updatedAt),
        ),
      ]);

  static Map<String, dynamic> _firstObject(dynamic res) {
    if (res is Map && res['data'] is Map) {
      return Map<String, dynamic>.from(res['data'] as Map);
    }
    if (res is Map && res['product'] is Map) {
      return Map<String, dynamic>.from(res['product'] as Map);
    }
    if (res is Map) return Map<String, dynamic>.from(res);
    return const {};
  }

  static Product _toModel(ProductRow row) => Product(
        id: row.id,
        name: row.name,
        sku: row.sku,
        barcode: row.barcode,
        categoryId: row.categoryId,
        price: row.price,
        costPrice: row.costPrice,
        stock: row.stock,
        status: row.status,
        description: row.description,
        unitOfMeasure: row.unitOfMeasure,
        imageUrls: _decodeStringList(row.imageUrlsJson),
        brand: row.brand,
        reorderPoint: row.reorderPoint,
        unitsPerBox: row.unitsPerBox,
        boxCost: row.boxCost,
        updatedAt: row.updatedAt,
      );

  static List<String> _decodeStringList(String json) {
    try {
      final v = jsonDecode(json);
      if (v is List) return v.map((e) => e.toString()).toList();
    } catch (_) {}
    return const [];
  }
}

List _extractList(dynamic res) {
  if (res is List) return res;
  if (res is Map && res['data'] is List) return res['data'] as List;
  if (res is Map && res['products'] is List) return res['products'] as List;
  return const [];
}
