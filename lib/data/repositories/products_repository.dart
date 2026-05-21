import 'dart:convert';

import 'package:drift/drift.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/product.dart';

class ProductsRepository {
  ProductsRepository({required this.api, required this.db});
  final ApiClient api;
  final AppDatabase db;

  Stream<List<Product>> watchActive() {
    return db.watchActiveProducts().map((rows) => rows.map(_toModel).toList());
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
