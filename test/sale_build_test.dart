import 'package:flutter_test/flutter_test.dart';

import 'package:salepilot_desktop/data/api/api_client.dart';
import 'package:salepilot_desktop/data/db/app_database.dart';
import 'package:salepilot_desktop/data/models/sale.dart';
import 'package:salepilot_desktop/data/repositories/products_repository.dart';
import 'package:salepilot_desktop/data/repositories/sales_repository.dart';
import 'package:drift/native.dart';

ApiClient _fakeApi() => ApiClient(
      baseUrl: 'http://localhost:0/api',
      tokenProvider: () async => null,
    );

void main() {
  test('buildSale produces unique transaction IDs and ISO timestamps', () {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final api = _fakeApi();
    final products = ProductsRepository(api: api, db: db);
    final repo = SalesRepository(api: api, db: db, products: products);

    final a = repo.buildSale(
      cart: [
        CartItem(productId: 'p', name: 'P', sku: 'sku', price: 5, quantity: 1, stock: 10),
      ],
      subtotal: 5,
      tax: 0,
      discount: 0,
      total: 5,
      amountPaid: 5,
      paymentStatus: 'paid',
    );
    final b = repo.buildSale(
      cart: [],
      subtotal: 0,
      tax: 0,
      discount: 0,
      total: 0,
      amountPaid: 0,
      paymentStatus: 'paid',
    );

    expect(a.transactionId, isNot(b.transactionId));
    expect(a.transactionId.length, greaterThan(20)); // UUID-ish
    expect(DateTime.tryParse(a.timestamp), isNotNull);
    expect(a.toJson()['refundStatus'], 'none');
  });
}
