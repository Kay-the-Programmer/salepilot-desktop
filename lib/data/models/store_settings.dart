class PaymentMethod {
  const PaymentMethod({required this.id, required this.name});
  final String id;
  final String name;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: (json['id'] ?? json['name'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class StoreSettings {
  StoreSettings({
    this.storeName = 'SalePilot Store',
    this.currencyCode = 'USD',
    this.currencySymbol = '\$',
    this.taxRate = 0,
    this.taxName = 'Tax',
    this.paymentMethods = const [],
    this.address,
    this.phone,
    this.email,
    this.receiptFooter,
  });

  final String storeName;
  final String currencyCode;
  final String currencySymbol;
  final double taxRate; // percent, e.g. 7.5
  final String taxName;
  final List<PaymentMethod> paymentMethods;
  final String? address;
  final String? phone;
  final String? email;
  final String? receiptFooter;

  static const _defaultMethods = <PaymentMethod>[
    PaymentMethod(id: 'pm_cash', name: 'Cash'),
    PaymentMethod(id: 'pm_card', name: 'Card'),
    PaymentMethod(id: 'pm_mobile', name: 'Mobile Money'),
  ];

  List<PaymentMethod> get effectiveMethods =>
      paymentMethods.isNotEmpty ? paymentMethods : _defaultMethods;

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    final pm = json['paymentMethods'];
    return StoreSettings(
      storeName: (json['storeName'] ?? json['name'] ?? 'SalePilot Store').toString(),
      currencyCode: (json['currencyCode'] ?? 'USD').toString(),
      currencySymbol: (json['currencySymbol'] ?? '\$').toString(),
      taxRate: _toDouble(json['taxRate']),
      taxName: (json['taxName'] ?? 'Tax').toString(),
      paymentMethods: pm is List
          ? pm.map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      receiptFooter: json['receiptFooter']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'currencyCode': currencyCode,
        'currencySymbol': currencySymbol,
        'taxRate': taxRate,
        'taxName': taxName,
        'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (receiptFooter != null) 'receiptFooter': receiptFooter,
      };
}
