class Product {
  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.status,
    this.description = '',
    this.barcode,
    this.categoryId,
    this.costPrice,
    this.unitOfMeasure = 'unit',
    this.imageUrls = const [],
    this.brand,
    this.reorderPoint,
    this.unitsPerBox,
    this.boxCost,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String? categoryId;
  final double price;
  final double? costPrice;
  final double stock;
  final String status; // 'active' | 'archived'
  final String description;
  final String unitOfMeasure; // 'unit' | 'kg'
  final List<String> imageUrls;
  final String? brand;
  final double? reorderPoint;
  /// How many sellable units make up one received box/carton (for the
  /// "receive shipment" flow). Null when never configured.
  final int? unitsPerBox;
  /// Cost of one box/carton, used to derive per-unit cost on receiving.
  final double? boxCost;
  final String? updatedAt;

  bool get isActive => status == 'active';
  bool get isWeighed => unitOfMeasure == 'kg';
  double get step => isWeighed ? 0.1 : 1.0;

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    double? price,
    double? costPrice,
    double? stock,
    String? status,
    String? description,
    String? unitOfMeasure,
    List<String>? imageUrls,
    String? brand,
    double? reorderPoint,
    int? unitsPerBox,
    double? boxCost,
    String? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      description: description ?? this.description,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      imageUrls: imageUrls ?? this.imageUrls,
      brand: brand ?? this.brand,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unitsPerBox: unitsPerBox ?? this.unitsPerBox,
      boxCost: boxCost ?? this.boxCost,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imgs = json['imageUrls'];
    return Product(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      barcode: json['barcode']?.toString(),
      categoryId: json['categoryId']?.toString(),
      price: _toDouble(json['price']),
      costPrice: _toDoubleOrNull(json['costPrice']),
      stock: _toDouble(json['stock']),
      status: (json['status'] ?? 'active').toString(),
      description: (json['description'] ?? '').toString(),
      unitOfMeasure: (json['unitOfMeasure'] ?? 'unit').toString(),
      imageUrls: imgs is List ? imgs.map((e) => e.toString()).toList() : const [],
      brand: json['brand']?.toString(),
      reorderPoint: _toDoubleOrNull(json['reorderPoint']),
      unitsPerBox: _toIntOrNull(json['unitsPerBox']),
      boxCost: _toDoubleOrNull(json['boxCost']),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        if (barcode != null) 'barcode': barcode,
        if (categoryId != null) 'categoryId': categoryId,
        'price': price,
        if (costPrice != null) 'costPrice': costPrice,
        'stock': stock,
        'status': status,
        'description': description,
        'unitOfMeasure': unitOfMeasure,
        'imageUrls': imageUrls,
        if (brand != null) 'brand': brand,
        if (reorderPoint != null) 'reorderPoint': reorderPoint,
        if (unitsPerBox != null) 'unitsPerBox': unitsPerBox,
        if (boxCost != null) 'boxCost': boxCost,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}
