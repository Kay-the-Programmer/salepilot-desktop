class Customer {
  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.storeCredit = 0,
    this.accountBalance = 0,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final double storeCredit;
  final double accountBalance;

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        storeCredit: _toDouble(json['storeCredit']),
        accountBalance: _toDouble(json['accountBalance']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'storeCredit': storeCredit,
        'accountBalance': accountBalance,
      };
}
