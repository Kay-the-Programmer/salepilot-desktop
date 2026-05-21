import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salepilot_desktop/data/api/api_client.dart';
import 'package:salepilot_desktop/data/db/app_database.dart';
import 'package:salepilot_desktop/data/models/return_record.dart';
import 'package:salepilot_desktop/data/models/sale.dart';
import 'package:salepilot_desktop/data/repositories/products_repository.dart';
import 'package:salepilot_desktop/data/repositories/returns_repository.dart';
import 'package:salepilot_desktop/data/repositories/sales_repository.dart';

ApiClient _api() => ApiClient(
      baseUrl: 'http://localhost:0/api',
      tokenProvider: () async => null,
    );

void main() {
  late AppDatabase db;
  late ProductsRepository products;
  late SalesRepository sales;
  late ReturnsRepository returns;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final api = _api();
    products = ProductsRepository(api: api, db: db);
    sales = SalesRepository(api: api, db: db, products: products);
    returns = ReturnsRepository(api: api, db: db, products: products);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Sale> persistSale({double tax = 0}) async {
    final sale = sales.buildSale(
      cart: [
        CartItem(productId: 'p1', name: 'Cola', sku: 'COLA', price: 2, quantity: 3, stock: 10),
        CartItem(productId: 'p2', name: 'Chips', sku: 'CHIP', price: 1, quantity: 2, stock: 5),
      ],
      subtotal: 8,
      tax: tax,
      discount: 0,
      total: 8 + tax,
      amountPaid: 8 + tax,
      paymentStatus: 'paid',
    );
    await sales.finalizeSale(sale);
    return sale;
  }

  test('partial return: queues POST, marks sale partially_refunded, restocks selected items', () async {
    // Seed products so stock increments are observable.
    await db.upsertProducts([
      ProductsCompanion.insert(id: 'p1', name: 'Cola', sku: 'COLA', price: 2, stock: 7),
      ProductsCompanion.insert(id: 'p2', name: 'Chips', sku: 'CHIP', price: 1, stock: 3),
    ]);
    final sale = await persistSale(tax: 0);

    await returns.createReturn(
      originalSale: sale,
      items: [
        ReturnLineItem(
          productId: 'p1',
          productName: 'Cola',
          quantity: 1,
          reason: 'Customer return',
          addToStock: true,
          unitPrice: 2,
        ),
      ],
      taxRefund: 0,
      refundMethod: 'Cash',
    );

    // Sale payload annotated.
    final row = (await db.recentSales(limit: 10)).firstWhere((r) => r.transactionId == sale.transactionId);
    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    expect(json['refundStatus'], 'partially_refunded');
    expect((json['totalRefunded'] as num).toDouble(), closeTo(2.0, 1e-9));

    // Restock applied: sale decremented p1 by 3 (7→4), return added 1 back (4→5).
    final p1 = await db.findProductByBarcodeOrSku('COLA');
    expect(p1!.stock, closeTo(5.0, 1e-9));
    // p2 not returned; sale decremented by 2 (3→1).
    final p2 = await db.findProductByBarcodeOrSku('CHIP');
    expect(p2!.stock, closeTo(1.0, 1e-9));

    // Two sync queue entries: the original sale + the return.
    final due = await db.dueSyncEntries(now: DateTime.now().millisecondsSinceEpoch + 1);
    expect(due.map((e) => e.endpoint).toSet(), {'/sales', '/returns'});
  });

  test('full return marks sale fully_refunded with proportional tax refund', () async {
    final sale = await persistSale(tax: 0.8); // 10% on $8

    await returns.createReturn(
      originalSale: sale,
      items: [
        ReturnLineItem(productId: 'p1', productName: 'Cola', quantity: 3, reason: 'X', addToStock: false, unitPrice: 2),
        ReturnLineItem(productId: 'p2', productName: 'Chips', quantity: 2, reason: 'X', addToStock: false, unitPrice: 1),
      ],
      taxRefund: 0.8,
      refundMethod: 'Cash',
    );

    final row = (await db.recentSales(limit: 10)).first;
    final json = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    expect(json['refundStatus'], 'fully_refunded');
    expect((json['totalRefunded'] as num).toDouble(), closeTo(8.8, 1e-9));
  });

  test('addToStock=false does not increment local stock', () async {
    await db.upsertProducts([
      ProductsCompanion.insert(id: 'p1', name: 'Cola', sku: 'COLA', price: 2, stock: 7),
    ]);
    final sale = await persistSale();
    await returns.createReturn(
      originalSale: sale,
      items: [
        ReturnLineItem(productId: 'p1', productName: 'Cola', quantity: 1, reason: 'X', addToStock: false, unitPrice: 2),
      ],
      taxRefund: 0,
      refundMethod: 'Cash',
    );
    // Sale decremented p1 stock by 3 (7→4); return with addToStock=false should leave it at 4.
    final p1 = await db.findProductByBarcodeOrSku('COLA');
    expect(p1!.stock, 4.0);
  });
}
