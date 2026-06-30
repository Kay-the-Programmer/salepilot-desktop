import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/customer.dart';
import '../../data/models/product.dart';
import '../../data/models/sale.dart';

enum DiscountType { amount, percentage }

class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discountAmount,
    required this.tax,
    required this.totalBeforeCredit,
    required this.appliedStoreCredit,
    required this.total,
    required this.itemCount,
  });

  final double subtotal;
  final double discountAmount;
  final double tax;
  final double totalBeforeCredit;
  final double appliedStoreCredit;
  final double total;
  final int itemCount;
}

class CartState {
  CartState({
    this.items = const [],
    this.discount = 0,
    this.discountType = DiscountType.amount,
    this.customer,
    this.appliedStoreCredit = 0,
    this.paymentMethod,
    this.cashReceived = 0,
    this.taxRate = 0,
  });

  final List<CartItem> items;
  final double discount;
  final DiscountType discountType;
  final Customer? customer;
  final double appliedStoreCredit;
  final String? paymentMethod;
  final double cashReceived;
  final double taxRate; // percent, e.g. 7.5

  CartState copyWith({
    List<CartItem>? items,
    double? discount,
    DiscountType? discountType,
    Customer? customer,
    bool clearCustomer = false,
    double? appliedStoreCredit,
    String? paymentMethod,
    double? cashReceived,
    double? taxRate,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      customer: clearCustomer ? null : (customer ?? this.customer),
      appliedStoreCredit: appliedStoreCredit ?? this.appliedStoreCredit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  CartTotals totals() {
    final subtotal = items.fold<double>(0, (sum, it) => sum + it.lineTotal);
    final discountAmount = discountType == DiscountType.percentage
        ? subtotal * (discount / 100)
        : discount;
    final afterDiscount = (subtotal - discountAmount).clamp(0, double.infinity);
    final tax = afterDiscount * (taxRate / 100);
    final totalBeforeCredit = afterDiscount + tax;
    final credit = appliedStoreCredit.clamp(0, totalBeforeCredit).toDouble();
    final total = totalBeforeCredit - credit;
    final itemCount = items.length;
    return CartTotals(
      subtotal: subtotal,
      discountAmount: discountAmount,
      tax: tax,
      totalBeforeCredit: totalBeforeCredit,
      appliedStoreCredit: credit,
      total: total,
      itemCount: itemCount,
    );
  }
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(CartState());

  static const _epsilon = 1e-9;

  double _round(double q) => (q * 1000).round() / 1000;

  /// Returns null on success, or a reason string on failure (e.g. out of stock).
  String? addProduct(Product product) {
    if (!product.isActive) return 'Product is archived';
    final step = product.step;
    final existing = state.items.where((i) => i.productId == product.id).toList();
    final inCart = existing.isEmpty ? 0.0 : existing.first.quantity;
    final next = _round(inCart + step);
    if (next > product.stock + _epsilon) {
      return 'Out of stock';
    }
    if (existing.isEmpty) {
      state = state.copyWith(items: [
        CartItem(
          productId: product.id,
          name: product.name,
          sku: product.sku,
          price: product.price,
          quantity: step,
          stock: product.stock,
          unitOfMeasure: product.unitOfMeasure,
          costPrice: product.costPrice,
        ),
        ...state.items,
      ]);
    } else {
      _updateQty(product.id, next);
    }
    return null;
  }

  void setQuantity(String productId, double quantity) {
    final item = state.items.firstWhere((i) => i.productId == productId, orElse: () => _missing());
    if (item.productId.isEmpty) return;
    final clamped = _round(quantity.clamp(0, item.stock).toDouble());
    if (clamped <= 0) {
      remove(productId);
      return;
    }
    _updateQty(productId, clamped);
  }

  void increment(String productId) {
    final item = state.items.firstWhere((i) => i.productId == productId, orElse: () => _missing());
    if (item.productId.isEmpty) return;
    final next = _round(item.quantity + item.step);
    if (next > item.stock + _epsilon) return;
    _updateQty(productId, next);
  }

  void decrement(String productId) {
    final item = state.items.firstWhere((i) => i.productId == productId, orElse: () => _missing());
    if (item.productId.isEmpty) return;
    final next = _round(item.quantity - item.step);
    if (next <= 0) {
      remove(productId);
    } else {
      _updateQty(productId, next);
    }
  }

  void _updateQty(String productId, double q) {
    state = state.copyWith(
      items: state.items
          .map((i) => i.productId == productId ? i.copyWith(quantity: q) : i)
          .toList(),
    );
  }

  void remove(String productId) {
    state = state.copyWith(items: state.items.where((i) => i.productId != productId).toList());
  }

  void clear() {
    state = CartState(taxRate: state.taxRate, paymentMethod: state.paymentMethod);
  }

  void replaceItems(List<CartItem> items) {
    state = state.copyWith(items: items);
  }

  void setDiscount(double value, DiscountType type) {
    state = state.copyWith(discount: value, discountType: type);
  }

  void setCustomer(Customer? customer) {
    if (customer == null) {
      state = state.copyWith(clearCustomer: true, appliedStoreCredit: 0);
    } else {
      state = state.copyWith(customer: customer);
    }
  }

  void applyStoreCredit() {
    final t = state.totals();
    if (t.appliedStoreCredit > 0) {
      state = state.copyWith(appliedStoreCredit: 0);
    } else {
      final credit = state.customer?.storeCredit ?? 0;
      final toApply = credit.clamp(0, t.totalBeforeCredit).toDouble();
      state = state.copyWith(appliedStoreCredit: toApply);
    }
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(paymentMethod: method, cashReceived: 0);
  }

  void setCashReceived(double value) {
    state = state.copyWith(cashReceived: value);
  }

  void setTaxRate(double percent) {
    state = state.copyWith(taxRate: percent);
  }

  CartItem _missing() => CartItem(
        productId: '',
        name: '',
        sku: '',
        price: 0,
        quantity: 0,
        stock: 0,
      );
}

final StateNotifierProvider<CartController, CartState> cartProvider =
    StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});

/// Live totals for the current cart. Recomputes whenever the cart changes.
final Provider<CartTotals> cartTotalsProvider = Provider<CartTotals>((ref) {
  return ref.watch(cartProvider).totals();
});

/// Whether the current cart can be charged (items + method chosen + enough
/// cash for cash payments).
final Provider<bool> canChargeProvider = Provider<bool>((ref) {
  return ref.watch(chargeBlockerProvider) == null;
});

/// Human-readable reason the cart can't be charged yet, or null when it can.
final Provider<String?> chargeBlockerProvider = Provider<String?>((ref) {
  final cart = ref.watch(cartProvider);
  if (cart.items.isEmpty) return 'Add items to the cart';
  if (cart.paymentMethod == null) return 'Choose a payment method';
  final isCash = cart.paymentMethod!.toLowerCase().contains('cash');
  if (isCash && cart.cashReceived < cart.totals().total) {
    return 'Enter enough cash';
  }
  return null;
});
