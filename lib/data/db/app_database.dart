import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get price => real()();
  RealColumn get costPrice => real().nullable()();
  RealColumn get stock => real()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get unitOfMeasure => text().withDefault(const Constant('unit'))();
  TextColumn get imageUrlsJson => text().withDefault(const Constant('[]'))();
  TextColumn get brand => text().nullable()();
  RealColumn get reorderPoint => real().nullable()();
  IntColumn get unitsPerBox => integer().nullable()();
  RealColumn get boxCost => real().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  RealColumn get storeCredit => real().withDefault(const Constant(0))();
  RealColumn get accountBalance => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingsRow')
class SettingsKv extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('SaleRow')
class Sales extends Table {
  TextColumn get transactionId => text()();
  TextColumn get timestamp => text()();
  TextColumn get payloadJson => text()();
  RealColumn get total => real()();
  TextColumn get customerName => text().nullable()();
  IntColumn get synced => integer().withDefault(const Constant(0))(); // 0 = no, 1 = yes

  @override
  Set<Column> get primaryKey => {transactionId};
}

@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get method => text().withDefault(const Constant('POST'))();
  TextColumn get bodyJson => text()();
  TextColumn get refKey => text().nullable()(); // e.g. sale transactionId
  IntColumn get retries => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get nextAttemptAt => integer().withDefault(const Constant(0))();
}

@DataClassName('HeldSaleRow')
class HeldSales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cartJson => text()();
  IntColumn get createdAt => integer()();
  TextColumn get note => text().nullable()();
}

/// One product in the active cycle-count session. The whole table is the
/// session: a non-empty table means a count is in progress.
@DataClassName('StockTakeItemRow')
class StockTakeItems extends Table {
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get productSku => text()();
  RealColumn get expectedQty => real()();
  RealColumn get countedQty => real().nullable()(); // null = not yet counted
  TextColumn get unitOfMeasure => text().withDefault(const Constant('unit'))();
  IntColumn get sessionStartedAt => integer()();

  @override
  Set<Column> get primaryKey => {productId};
}

/// Local audit log of stock changes (adjustments + received shipments).
@DataClassName('StockMovementRow')
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get delta => real()();
  RealColumn get previousStock => real()();
  RealColumn get newStock => real()();
  TextColumn get reason => text()();
  IntColumn get createdAt => integer()();
  IntColumn get synced => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [
  Products,
  Categories,
  Customers,
  SettingsKv,
  Sales,
  SyncQueue,
  HeldSales,
  StockTakeItems,
  StockMovements,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(products, products.unitsPerBox);
            await m.addColumn(products, products.boxCost);
            await m.createTable(stockTakeItems);
            await m.createTable(stockMovements);
          }
        },
      );

  // ---- Products ----
  Future<List<ProductRow>> allActiveProducts() =>
      (select(products)..where((p) => p.status.equals('active'))..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .get();

  Stream<List<ProductRow>> watchActiveProducts() =>
      (select(products)..where((p) => p.status.equals('active'))..orderBy([(p) => OrderingTerm(expression: p.name)]))
          .watch();

  Stream<List<ProductRow>> watchAllProducts() =>
      (select(products)..orderBy([(p) => OrderingTerm(expression: p.name)])).watch();

  Future<ProductRow?> productById(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Partial update — only the columns set on [changes] are written.
  Future<void> updateProductRow(String id, ProductsCompanion changes) =>
      (update(products)..where((p) => p.id.equals(id))).write(changes);

  Future<void> deleteProductById(String id) =>
      (delete(products)..where((p) => p.id.equals(id))).go();

  Future<ProductRow?> findProductByBarcodeOrSku(String code) async {
    final q = select(products)
      ..where((p) => p.status.equals('active') & (p.barcode.equals(code) | p.sku.equals(code)))
      ..limit(1);
    final rows = await q.get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsertProducts(List<Insertable<ProductRow>> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(products, rows);
    });
  }

  Future<void> clearProducts() => delete(products).go();

  // ---- Categories ----
  Future<List<CategoryRow>> allCategories() => select(categories).get();
  Stream<List<CategoryRow>> watchCategories() => select(categories).watch();
  Future<void> upsertCategories(List<Insertable<CategoryRow>> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(categories, rows));
  }

  // ---- Customers ----
  Future<List<CustomerRow>> allCustomers() => select(customers).get();
  Stream<List<CustomerRow>> watchCustomers() => select(customers).watch();
  Future<void> upsertCustomers(List<Insertable<CustomerRow>> rows) async {
    await batch((b) => b.insertAllOnConflictUpdate(customers, rows));
  }

  // ---- Settings KV ----
  Future<String?> getSetting(String key) async {
    final row = await (select(settingsKv)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settingsKv).insertOnConflictUpdate(
      SettingsKvCompanion.insert(key: key, value: value),
    );
  }

  // ---- Sales ----
  Future<void> insertSale(SalesCompanion sale) => into(sales).insert(sale);

  Future<void> markSaleSynced(String transactionId) => (update(sales)
        ..where((t) => t.transactionId.equals(transactionId)))
      .write(const SalesCompanion(synced: Value(1)));

  Future<List<SaleRow>> recentSales({int limit = 50}) => (select(sales)
        ..orderBy([(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.desc)])
        ..limit(limit))
      .get();

  Stream<List<SaleRow>> watchAllSales() => (select(sales)
        ..orderBy([(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.desc)]))
      .watch();

  // ---- Sync queue ----
  Future<int> enqueueSync(SyncQueueCompanion entry) => into(syncQueue).insert(entry);

  Future<List<SyncQueueRow>> dueSyncEntries({required int now, int limit = 20}) => (select(syncQueue)
        ..where((q) => q.nextAttemptAt.isSmallerOrEqualValue(now))
        ..orderBy([(q) => OrderingTerm(expression: q.createdAt)])
        ..limit(limit))
      .get();

  Future<int> pendingSyncCount() async {
    final count = countAll();
    final query = selectOnly(syncQueue)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deleteSyncEntry(int id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> updateSyncFailure(int id, String error, int nextAttemptAt) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retries: const Value.absent(),
        lastError: Value(error),
        nextAttemptAt: Value(nextAttemptAt),
      ),
    );
    await customUpdate(
      'UPDATE sync_queue SET retries = retries + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {syncQueue},
    );
  }

  // ---- Held sales ----
  Future<int> addHeldSale(String cartJson, {String? note}) {
    return into(heldSales).insert(HeldSalesCompanion.insert(
      cartJson: cartJson,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      note: Value(note),
    ));
  }

  Future<List<HeldSaleRow>> listHeldSales() =>
      (select(heldSales)..orderBy([(h) => OrderingTerm(expression: h.createdAt, mode: OrderingMode.desc)])).get();

  Stream<List<HeldSaleRow>> watchHeldSales() =>
      (select(heldSales)..orderBy([(h) => OrderingTerm(expression: h.createdAt, mode: OrderingMode.desc)])).watch();

  Future<void> removeHeldSale(int id) =>
      (delete(heldSales)..where((t) => t.id.equals(id))).go();

  // ---- Stock take (cycle count) ----
  Stream<List<StockTakeItemRow>> watchStockTakeItems() =>
      (select(stockTakeItems)..orderBy([(t) => OrderingTerm(expression: t.productName)])).watch();

  Future<List<StockTakeItemRow>> allStockTakeItems() =>
      (select(stockTakeItems)..orderBy([(t) => OrderingTerm(expression: t.productName)])).get();

  Future<int> stockTakeItemCount() async {
    final c = countAll();
    final query = selectOnly(stockTakeItems)..addColumns([c]);
    final row = await query.getSingle();
    return row.read(c) ?? 0;
  }

  Future<void> seedStockTakeItems(List<Insertable<StockTakeItemRow>> rows) async {
    await transaction(() async {
      await delete(stockTakeItems).go();
      await batch((b) => b.insertAll(stockTakeItems, rows));
    });
  }

  Future<void> recordStockTakeCount(String productId, double counted) =>
      (update(stockTakeItems)..where((t) => t.productId.equals(productId)))
          .write(StockTakeItemsCompanion(countedQty: Value(counted)));

  Future<void> clearStockTakeItem(String productId) =>
      (update(stockTakeItems)..where((t) => t.productId.equals(productId)))
          .write(const StockTakeItemsCompanion(countedQty: Value(null)));

  Future<void> clearStockTakeItems() => delete(stockTakeItems).go();

  // ---- Stock movements (local audit log) ----
  Future<int> insertStockMovement(StockMovementsCompanion movement) =>
      into(stockMovements).insert(movement);

  Stream<List<StockMovementRow>> watchStockMovements({int limit = 100, String? productId}) {
    final q = select(stockMovements)
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)])
      ..limit(limit);
    if (productId != null) {
      q.where((m) => m.productId.equals(productId));
    }
    return q.watch();
  }
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(dir.path, 'salepilot.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
