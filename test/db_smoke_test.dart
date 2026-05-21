import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salepilot_desktop/data/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert + query products', () async {
    await db.upsertProducts([
      ProductsCompanion.insert(
        id: 'p1',
        name: 'Cola',
        sku: 'COLA-1',
        price: 1.5,
        stock: 10,
        barcode: const Value('123'),
      ),
    ]);
    final all = await db.allActiveProducts();
    expect(all, hasLength(1));
    expect(all.first.name, 'Cola');

    final byBarcode = await db.findProductByBarcodeOrSku('123');
    expect(byBarcode?.id, 'p1');
    final bySku = await db.findProductByBarcodeOrSku('COLA-1');
    expect(bySku?.id, 'p1');
    final missing = await db.findProductByBarcodeOrSku('nope');
    expect(missing, isNull);
  });

  test('sale + sync queue lifecycle', () async {
    await db.insertSale(SalesCompanion.insert(
      transactionId: 'tx-1',
      timestamp: DateTime.now().toIso8601String(),
      payloadJson: '{"transactionId":"tx-1"}',
      total: 12.5,
    ));
    final id = await db.enqueueSync(SyncQueueCompanion.insert(
      endpoint: '/sales',
      bodyJson: '{"transactionId":"tx-1"}',
      refKey: const Value('tx-1'),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    expect(await db.pendingSyncCount(), 1);

    final due = await db.dueSyncEntries(now: DateTime.now().millisecondsSinceEpoch + 1);
    expect(due, hasLength(1));
    expect(due.first.id, id);
    expect(due.first.refKey, 'tx-1');

    await db.markSaleSynced('tx-1');
    await db.deleteSyncEntry(id);
    expect(await db.pendingSyncCount(), 0);
  });

  test('held sales survive', () async {
    final cart = jsonEncode([
      {'productId': 'p1', 'name': 'A', 'sku': 'A', 'price': 1, 'quantity': 1, 'stock': 5}
    ]);
    final id = await db.addHeldSale(cart, note: 'lunch break');
    final all = await db.listHeldSales();
    expect(all, hasLength(1));
    expect(all.first.note, 'lunch break');

    await db.removeHeldSale(id);
    expect(await db.listHeldSales(), isEmpty);
  });

  test('settings KV upserts', () async {
    expect(await db.getSetting('foo'), isNull);
    await db.setSetting('foo', 'bar');
    expect(await db.getSetting('foo'), 'bar');
    await db.setSetting('foo', 'baz');
    expect(await db.getSetting('foo'), 'baz');
  });
}
