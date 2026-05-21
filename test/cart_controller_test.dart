import 'package:flutter_test/flutter_test.dart';

import 'package:salepilot_desktop/data/models/customer.dart';
import 'package:salepilot_desktop/data/models/product.dart';
import 'package:salepilot_desktop/features/pos/cart_controller.dart';

void main() {
  Product p({
    String id = 'p1',
    String name = 'Test Product',
    double price = 10,
    double stock = 5,
    String uom = 'unit',
  }) {
    return Product(id: id, name: name, sku: id, price: price, stock: stock, status: 'active', unitOfMeasure: uom);
  }

  test('add product, increment, decrement, remove', () {
    final c = CartController();
    expect(c.addProduct(p()), isNull);
    expect(c.state.items.length, 1);
    expect(c.state.items.first.quantity, 1);

    c.increment('p1');
    expect(c.state.items.first.quantity, 2);

    c.decrement('p1');
    expect(c.state.items.first.quantity, 1);

    c.remove('p1');
    expect(c.state.items, isEmpty);
  });

  test('out-of-stock blocks adding past stock', () {
    final c = CartController();
    final prod = p(stock: 2);
    expect(c.addProduct(prod), isNull);
    expect(c.addProduct(prod), isNull);
    expect(c.addProduct(prod), 'Out of stock');
    expect(c.state.items.first.quantity, 2);
  });

  test('weighed products step by 0.1', () {
    final c = CartController();
    final kg = p(uom: 'kg', stock: 1);
    c.addProduct(kg);
    expect(c.state.items.first.quantity, closeTo(0.1, 1e-9));
    c.increment('p1');
    expect(c.state.items.first.quantity, closeTo(0.2, 1e-9));
  });

  test('totals: subtotal, discount, tax, store credit', () {
    final c = CartController();
    c.addProduct(p(price: 10, stock: 5)); // qty 1
    c.increment('p1'); // qty 2 -> subtotal 20
    c.setDiscount(5, DiscountType.amount);
    c.setTaxRate(10); // 10%
    var t = c.state.totals();
    expect(t.subtotal, 20);
    expect(t.discountAmount, 5);
    // afterDiscount = 15, tax = 1.5, total = 16.5
    expect(t.tax, closeTo(1.5, 1e-9));
    expect(t.total, closeTo(16.5, 1e-9));

    // Percentage discount
    c.setDiscount(10, DiscountType.percentage); // 10% of 20 = 2
    t = c.state.totals();
    expect(t.discountAmount, closeTo(2, 1e-9));
    expect(t.total, closeTo((20 - 2) * 1.1, 1e-9));

    // Store credit caps at totalBeforeCredit
    c.setCustomer(Customer(id: 'c1', name: 'C', storeCredit: 100));
    c.applyStoreCredit();
    t = c.state.totals();
    expect(t.appliedStoreCredit, closeTo(t.totalBeforeCredit, 1e-9));
    expect(t.total, closeTo(0, 1e-9));
  });

  test('decrementing to zero removes item', () {
    final c = CartController();
    c.addProduct(p(stock: 5));
    c.decrement('p1');
    expect(c.state.items, isEmpty);
  });

  test('setQuantity clamps to available stock', () {
    final c = CartController();
    c.addProduct(p(stock: 3));
    c.setQuantity('p1', 99);
    expect(c.state.items.first.quantity, 3);
  });
}
