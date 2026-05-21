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
  final String? updatedAt;

  bool get isActive => status == 'active';
  bool get isWeighed => unitOfMeasure == 'kg';
  double get step => isWeighed ? 0.1 : 1.0;

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
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}
