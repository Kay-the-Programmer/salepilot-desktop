class CartItem {
  CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.stock,
    this.unitOfMeasure = 'unit',
    this.costPrice,
  });

  final String productId;
  final String name;
  final String sku;
  final double price;
  final double quantity;
  final double stock; // available stock when item was added
  final String unitOfMeasure;
  final double? costPrice;

  double get lineTotal => price * quantity;
  bool get isWeighed => unitOfMeasure == 'kg';
  double get step => isWeighed ? 0.1 : 1.0;

  CartItem copyWith({double? quantity, double? stock}) => CartItem(
        productId: productId,
        name: name,
        sku: sku,
        price: price,
        quantity: quantity ?? this.quantity,
        stock: stock ?? this.stock,
        unitOfMeasure: unitOfMeasure,
        costPrice: costPrice,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'sku': sku,
        'price': price,
        'quantity': quantity,
        'stock': stock,
        'unitOfMeasure': unitOfMeasure,
        if (costPrice != null) 'costPrice': costPrice,
        'returnedQuantity': 0,
      };

  static CartItem fromJson(Map<String, dynamic> json) {
    double td(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return CartItem(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      price: td(json['price']),
      quantity: td(json['quantity']),
      stock: td(json['stock']),
      unitOfMeasure: (json['unitOfMeasure'] ?? 'unit').toString(),
      costPrice: json['costPrice'] == null ? null : td(json['costPrice']),
    );
  }
}

class Payment {
  Payment({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    this.reference,
  });

  final String id;
  final String date;
  final double amount;
  final String method;
  final String? reference;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'amount': amount,
        'method': method,
        if (reference != null) 'reference': reference,
      };
}

class Sale {
  Sale({
    required this.transactionId,
    required this.timestamp,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.amountPaid,
    required this.paymentStatus,
    this.storeCreditUsed = 0,
    this.customerId,
    this.customerName,
    this.cashReceived,
    this.changeDue,
    this.payments = const [],
    this.channel = 'pos',
  });

  final String transactionId;
  final String timestamp;
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final double amountPaid;
  final String paymentStatus; // 'paid' | 'unpaid' | 'partially_paid'
  final double storeCreditUsed;
  final String? customerId;
  final String? customerName;
  final double? cashReceived;
  final double? changeDue;
  final List<Payment> payments;
  final String channel;

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'timestamp': timestamp,
        'cart': cart.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'discount': discount,
        'total': total,
        'amountPaid': amountPaid,
        'paymentStatus': paymentStatus,
        'storeCreditUsed': storeCreditUsed,
        if (customerId != null) 'customerId': customerId,
        if (customerName != null) 'customerName': customerName,
        if (cashReceived != null) 'cashReceived': cashReceived,
        if (changeDue != null) 'changeDue': changeDue,
        'payments': payments.map((e) => e.toJson()).toList(),
        'channel': channel,
        'refundStatus': 'none',
      };
}
