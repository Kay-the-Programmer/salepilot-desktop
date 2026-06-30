// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitOfMeasureMeta = const VerificationMeta(
    'unitOfMeasure',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasure = GeneratedColumn<String>(
    'unit_of_measure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unit'),
  );
  static const VerificationMeta _imageUrlsJsonMeta = const VerificationMeta(
    'imageUrlsJson',
  );
  @override
  late final GeneratedColumn<String> imageUrlsJson = GeneratedColumn<String>(
    'image_urls_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reorderPointMeta = const VerificationMeta(
    'reorderPoint',
  );
  @override
  late final GeneratedColumn<double> reorderPoint = GeneratedColumn<double>(
    'reorder_point',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsPerBoxMeta = const VerificationMeta(
    'unitsPerBox',
  );
  @override
  late final GeneratedColumn<int> unitsPerBox = GeneratedColumn<int>(
    'units_per_box',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boxCostMeta = const VerificationMeta(
    'boxCost',
  );
  @override
  late final GeneratedColumn<double> boxCost = GeneratedColumn<double>(
    'box_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sku,
    barcode,
    categoryId,
    price,
    costPrice,
    stock,
    status,
    description,
    unitOfMeasure,
    imageUrlsJson,
    brand,
    reorderPoint,
    unitsPerBox,
    boxCost,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    } else if (isInserting) {
      context.missing(_stockMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('unit_of_measure')) {
      context.handle(
        _unitOfMeasureMeta,
        unitOfMeasure.isAcceptableOrUnknown(
          data['unit_of_measure']!,
          _unitOfMeasureMeta,
        ),
      );
    }
    if (data.containsKey('image_urls_json')) {
      context.handle(
        _imageUrlsJsonMeta,
        imageUrlsJson.isAcceptableOrUnknown(
          data['image_urls_json']!,
          _imageUrlsJsonMeta,
        ),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('reorder_point')) {
      context.handle(
        _reorderPointMeta,
        reorderPoint.isAcceptableOrUnknown(
          data['reorder_point']!,
          _reorderPointMeta,
        ),
      );
    }
    if (data.containsKey('units_per_box')) {
      context.handle(
        _unitsPerBoxMeta,
        unitsPerBox.isAcceptableOrUnknown(
          data['units_per_box']!,
          _unitsPerBoxMeta,
        ),
      );
    }
    if (data.containsKey('box_cost')) {
      context.handle(
        _boxCostMeta,
        boxCost.isAcceptableOrUnknown(data['box_cost']!, _boxCostMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      unitOfMeasure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure'],
      )!,
      imageUrlsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_urls_json'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      reorderPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_point'],
      ),
      unitsPerBox: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_box'],
      ),
      boxCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}box_cost'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String? categoryId;
  final double price;
  final double? costPrice;
  final double stock;
  final String status;
  final String description;
  final String unitOfMeasure;
  final String imageUrlsJson;
  final String? brand;
  final double? reorderPoint;
  final int? unitsPerBox;
  final double? boxCost;
  final String? updatedAt;
  const ProductRow({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryId,
    required this.price,
    this.costPrice,
    required this.stock,
    required this.status,
    required this.description,
    required this.unitOfMeasure,
    required this.imageUrlsJson,
    this.brand,
    this.reorderPoint,
    this.unitsPerBox,
    this.boxCost,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sku'] = Variable<String>(sku);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || costPrice != null) {
      map['cost_price'] = Variable<double>(costPrice);
    }
    map['stock'] = Variable<double>(stock);
    map['status'] = Variable<String>(status);
    map['description'] = Variable<String>(description);
    map['unit_of_measure'] = Variable<String>(unitOfMeasure);
    map['image_urls_json'] = Variable<String>(imageUrlsJson);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || reorderPoint != null) {
      map['reorder_point'] = Variable<double>(reorderPoint);
    }
    if (!nullToAbsent || unitsPerBox != null) {
      map['units_per_box'] = Variable<int>(unitsPerBox);
    }
    if (!nullToAbsent || boxCost != null) {
      map['box_cost'] = Variable<double>(boxCost);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      price: Value(price),
      costPrice: costPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(costPrice),
      stock: Value(stock),
      status: Value(status),
      description: Value(description),
      unitOfMeasure: Value(unitOfMeasure),
      imageUrlsJson: Value(imageUrlsJson),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      reorderPoint: reorderPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(reorderPoint),
      unitsPerBox: unitsPerBox == null && nullToAbsent
          ? const Value.absent()
          : Value(unitsPerBox),
      boxCost: boxCost == null && nullToAbsent
          ? const Value.absent()
          : Value(boxCost),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      price: serializer.fromJson<double>(json['price']),
      costPrice: serializer.fromJson<double?>(json['costPrice']),
      stock: serializer.fromJson<double>(json['stock']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String>(json['description']),
      unitOfMeasure: serializer.fromJson<String>(json['unitOfMeasure']),
      imageUrlsJson: serializer.fromJson<String>(json['imageUrlsJson']),
      brand: serializer.fromJson<String?>(json['brand']),
      reorderPoint: serializer.fromJson<double?>(json['reorderPoint']),
      unitsPerBox: serializer.fromJson<int?>(json['unitsPerBox']),
      boxCost: serializer.fromJson<double?>(json['boxCost']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'categoryId': serializer.toJson<String?>(categoryId),
      'price': serializer.toJson<double>(price),
      'costPrice': serializer.toJson<double?>(costPrice),
      'stock': serializer.toJson<double>(stock),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String>(description),
      'unitOfMeasure': serializer.toJson<String>(unitOfMeasure),
      'imageUrlsJson': serializer.toJson<String>(imageUrlsJson),
      'brand': serializer.toJson<String?>(brand),
      'reorderPoint': serializer.toJson<double?>(reorderPoint),
      'unitsPerBox': serializer.toJson<int?>(unitsPerBox),
      'boxCost': serializer.toJson<double?>(boxCost),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  ProductRow copyWith({
    String? id,
    String? name,
    String? sku,
    Value<String?> barcode = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    double? price,
    Value<double?> costPrice = const Value.absent(),
    double? stock,
    String? status,
    String? description,
    String? unitOfMeasure,
    String? imageUrlsJson,
    Value<String?> brand = const Value.absent(),
    Value<double?> reorderPoint = const Value.absent(),
    Value<int?> unitsPerBox = const Value.absent(),
    Value<double?> boxCost = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku ?? this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    price: price ?? this.price,
    costPrice: costPrice.present ? costPrice.value : this.costPrice,
    stock: stock ?? this.stock,
    status: status ?? this.status,
    description: description ?? this.description,
    unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
    imageUrlsJson: imageUrlsJson ?? this.imageUrlsJson,
    brand: brand.present ? brand.value : this.brand,
    reorderPoint: reorderPoint.present ? reorderPoint.value : this.reorderPoint,
    unitsPerBox: unitsPerBox.present ? unitsPerBox.value : this.unitsPerBox,
    boxCost: boxCost.present ? boxCost.value : this.boxCost,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      stock: data.stock.present ? data.stock.value : this.stock,
      status: data.status.present ? data.status.value : this.status,
      description: data.description.present
          ? data.description.value
          : this.description,
      unitOfMeasure: data.unitOfMeasure.present
          ? data.unitOfMeasure.value
          : this.unitOfMeasure,
      imageUrlsJson: data.imageUrlsJson.present
          ? data.imageUrlsJson.value
          : this.imageUrlsJson,
      brand: data.brand.present ? data.brand.value : this.brand,
      reorderPoint: data.reorderPoint.present
          ? data.reorderPoint.value
          : this.reorderPoint,
      unitsPerBox: data.unitsPerBox.present
          ? data.unitsPerBox.value
          : this.unitsPerBox,
      boxCost: data.boxCost.present ? data.boxCost.value : this.boxCost,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stock: $stock, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('imageUrlsJson: $imageUrlsJson, ')
          ..write('brand: $brand, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('boxCost: $boxCost, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sku,
    barcode,
    categoryId,
    price,
    costPrice,
    stock,
    status,
    description,
    unitOfMeasure,
    imageUrlsJson,
    brand,
    reorderPoint,
    unitsPerBox,
    boxCost,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.categoryId == this.categoryId &&
          other.price == this.price &&
          other.costPrice == this.costPrice &&
          other.stock == this.stock &&
          other.status == this.status &&
          other.description == this.description &&
          other.unitOfMeasure == this.unitOfMeasure &&
          other.imageUrlsJson == this.imageUrlsJson &&
          other.brand == this.brand &&
          other.reorderPoint == this.reorderPoint &&
          other.unitsPerBox == this.unitsPerBox &&
          other.boxCost == this.boxCost &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> sku;
  final Value<String?> barcode;
  final Value<String?> categoryId;
  final Value<double> price;
  final Value<double?> costPrice;
  final Value<double> stock;
  final Value<String> status;
  final Value<String> description;
  final Value<String> unitOfMeasure;
  final Value<String> imageUrlsJson;
  final Value<String?> brand;
  final Value<double?> reorderPoint;
  final Value<int?> unitsPerBox;
  final Value<double?> boxCost;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.imageUrlsJson = const Value.absent(),
    this.brand = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.unitsPerBox = const Value.absent(),
    this.boxCost = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String sku,
    this.barcode = const Value.absent(),
    this.categoryId = const Value.absent(),
    required double price,
    this.costPrice = const Value.absent(),
    required double stock,
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.imageUrlsJson = const Value.absent(),
    this.brand = const Value.absent(),
    this.reorderPoint = const Value.absent(),
    this.unitsPerBox = const Value.absent(),
    this.boxCost = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sku = Value(sku),
       price = Value(price),
       stock = Value(stock);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<String>? categoryId,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<double>? stock,
    Expression<String>? status,
    Expression<String>? description,
    Expression<String>? unitOfMeasure,
    Expression<String>? imageUrlsJson,
    Expression<String>? brand,
    Expression<double>? reorderPoint,
    Expression<int>? unitsPerBox,
    Expression<double>? boxCost,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (categoryId != null) 'category_id': categoryId,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (stock != null) 'stock': stock,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (unitOfMeasure != null) 'unit_of_measure': unitOfMeasure,
      if (imageUrlsJson != null) 'image_urls_json': imageUrlsJson,
      if (brand != null) 'brand': brand,
      if (reorderPoint != null) 'reorder_point': reorderPoint,
      if (unitsPerBox != null) 'units_per_box': unitsPerBox,
      if (boxCost != null) 'box_cost': boxCost,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? sku,
    Value<String?>? barcode,
    Value<String?>? categoryId,
    Value<double>? price,
    Value<double?>? costPrice,
    Value<double>? stock,
    Value<String>? status,
    Value<String>? description,
    Value<String>? unitOfMeasure,
    Value<String>? imageUrlsJson,
    Value<String?>? brand,
    Value<double?>? reorderPoint,
    Value<int?>? unitsPerBox,
    Value<double?>? boxCost,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
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
      imageUrlsJson: imageUrlsJson ?? this.imageUrlsJson,
      brand: brand ?? this.brand,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      unitsPerBox: unitsPerBox ?? this.unitsPerBox,
      boxCost: boxCost ?? this.boxCost,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (unitOfMeasure.present) {
      map['unit_of_measure'] = Variable<String>(unitOfMeasure.value);
    }
    if (imageUrlsJson.present) {
      map['image_urls_json'] = Variable<String>(imageUrlsJson.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (reorderPoint.present) {
      map['reorder_point'] = Variable<double>(reorderPoint.value);
    }
    if (unitsPerBox.present) {
      map['units_per_box'] = Variable<int>(unitsPerBox.value);
    }
    if (boxCost.present) {
      map['box_cost'] = Variable<double>(boxCost.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stock: $stock, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('imageUrlsJson: $imageUrlsJson, ')
          ..write('brand: $brand, ')
          ..write('reorderPoint: $reorderPoint, ')
          ..write('unitsPerBox: $unitsPerBox, ')
          ..write('boxCost: $boxCost, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String? parentId;
  const CategoryRow({required this.id, required this.name, this.parentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeCreditMeta = const VerificationMeta(
    'storeCredit',
  );
  @override
  late final GeneratedColumn<double> storeCredit = GeneratedColumn<double>(
    'store_credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountBalanceMeta = const VerificationMeta(
    'accountBalance',
  );
  @override
  late final GeneratedColumn<double> accountBalance = GeneratedColumn<double>(
    'account_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    phone,
    storeCredit,
    accountBalance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('store_credit')) {
      context.handle(
        _storeCreditMeta,
        storeCredit.isAcceptableOrUnknown(
          data['store_credit']!,
          _storeCreditMeta,
        ),
      );
    }
    if (data.containsKey('account_balance')) {
      context.handle(
        _accountBalanceMeta,
        accountBalance.isAcceptableOrUnknown(
          data['account_balance']!,
          _accountBalanceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      storeCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}store_credit'],
      )!,
      accountBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}account_balance'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final double storeCredit;
  final double accountBalance;
  const CustomerRow({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.storeCredit,
    required this.accountBalance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['store_credit'] = Variable<double>(storeCredit);
    map['account_balance'] = Variable<double>(accountBalance);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      storeCredit: Value(storeCredit),
      accountBalance: Value(accountBalance),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      storeCredit: serializer.fromJson<double>(json['storeCredit']),
      accountBalance: serializer.fromJson<double>(json['accountBalance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'storeCredit': serializer.toJson<double>(storeCredit),
      'accountBalance': serializer.toJson<double>(accountBalance),
    };
  }

  CustomerRow copyWith({
    String? id,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    double? storeCredit,
    double? accountBalance,
  }) => CustomerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    storeCredit: storeCredit ?? this.storeCredit,
    accountBalance: accountBalance ?? this.accountBalance,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      storeCredit: data.storeCredit.present
          ? data.storeCredit.value
          : this.storeCredit,
      accountBalance: data.accountBalance.present
          ? data.accountBalance.value
          : this.accountBalance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('storeCredit: $storeCredit, ')
          ..write('accountBalance: $accountBalance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, phone, storeCredit, accountBalance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.storeCredit == this.storeCredit &&
          other.accountBalance == this.accountBalance);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<double> storeCredit;
  final Value<double> accountBalance;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.storeCredit = const Value.absent(),
    this.accountBalance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.storeCredit = const Value.absent(),
    this.accountBalance = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<double>? storeCredit,
    Expression<double>? accountBalance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (storeCredit != null) 'store_credit': storeCredit,
      if (accountBalance != null) 'account_balance': accountBalance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phone,
    Value<double>? storeCredit,
    Value<double>? accountBalance,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      storeCredit: storeCredit ?? this.storeCredit,
      accountBalance: accountBalance ?? this.accountBalance,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (storeCredit.present) {
      map['store_credit'] = Variable<double>(storeCredit.value);
    }
    if (accountBalance.present) {
      map['account_balance'] = Variable<double>(accountBalance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('storeCredit: $storeCredit, ')
          ..write('accountBalance: $accountBalance, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsKvTable extends SettingsKv
    with TableInfo<$SettingsKvTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsKvTable createAlias(String alias) {
    return $SettingsKvTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final String key;
  final String value;
  const SettingsRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsKvCompanion toCompanion(bool nullToAbsent) {
    return SettingsKvCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsRow copyWith({String? key, String? value}) =>
      SettingsRow(key: key ?? this.key, value: value ?? this.value);
  SettingsRow copyWithCompanion(SettingsKvCompanion data) {
    return SettingsRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsKvCompanion extends UpdateCompanion<SettingsRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsKvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsKvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsKvCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsKvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsKvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<int> synced = GeneratedColumn<int>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    timestamp,
    payloadJson,
    total,
    customerName,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String transactionId;
  final String timestamp;
  final String payloadJson;
  final double total;
  final String? customerName;
  final int synced;
  const SaleRow({
    required this.transactionId,
    required this.timestamp,
    required this.payloadJson,
    required this.total,
    this.customerName,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<String>(transactionId);
    map['timestamp'] = Variable<String>(timestamp);
    map['payload_json'] = Variable<String>(payloadJson);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['synced'] = Variable<int>(synced);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      transactionId: Value(transactionId),
      timestamp: Value(timestamp),
      payloadJson: Value(payloadJson),
      total: Value(total),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      synced: Value(synced),
    );
  }

  factory SaleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      total: serializer.fromJson<double>(json['total']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      synced: serializer.fromJson<int>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'timestamp': serializer.toJson<String>(timestamp),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'total': serializer.toJson<double>(total),
      'customerName': serializer.toJson<String?>(customerName),
      'synced': serializer.toJson<int>(synced),
    };
  }

  SaleRow copyWith({
    String? transactionId,
    String? timestamp,
    String? payloadJson,
    double? total,
    Value<String?> customerName = const Value.absent(),
    int? synced,
  }) => SaleRow(
    transactionId: transactionId ?? this.transactionId,
    timestamp: timestamp ?? this.timestamp,
    payloadJson: payloadJson ?? this.payloadJson,
    total: total ?? this.total,
    customerName: customerName.present ? customerName.value : this.customerName,
    synced: synced ?? this.synced,
  );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      total: data.total.present ? data.total.value : this.total,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('transactionId: $transactionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('total: $total, ')
          ..write('customerName: $customerName, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    timestamp,
    payloadJson,
    total,
    customerName,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.transactionId == this.transactionId &&
          other.timestamp == this.timestamp &&
          other.payloadJson == this.payloadJson &&
          other.total == this.total &&
          other.customerName == this.customerName &&
          other.synced == this.synced);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> transactionId;
  final Value<String> timestamp;
  final Value<String> payloadJson;
  final Value<double> total;
  final Value<String?> customerName;
  final Value<int> synced;
  final Value<int> rowid;
  const SalesCompanion({
    this.transactionId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.total = const Value.absent(),
    this.customerName = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String transactionId,
    required String timestamp,
    required String payloadJson,
    required double total,
    this.customerName = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       timestamp = Value(timestamp),
       payloadJson = Value(payloadJson),
       total = Value(total);
  static Insertable<SaleRow> custom({
    Expression<String>? transactionId,
    Expression<String>? timestamp,
    Expression<String>? payloadJson,
    Expression<double>? total,
    Expression<String>? customerName,
    Expression<int>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (timestamp != null) 'timestamp': timestamp,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (total != null) 'total': total,
      if (customerName != null) 'customer_name': customerName,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? transactionId,
    Value<String>? timestamp,
    Value<String>? payloadJson,
    Value<double>? total,
    Value<String?>? customerName,
    Value<int>? synced,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      payloadJson: payloadJson ?? this.payloadJson,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (synced.present) {
      map['synced'] = Variable<int>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('total: $total, ')
          ..write('customerName: $customerName, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('POST'),
  );
  static const VerificationMeta _bodyJsonMeta = const VerificationMeta(
    'bodyJson',
  );
  @override
  late final GeneratedColumn<String> bodyJson = GeneratedColumn<String>(
    'body_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refKeyMeta = const VerificationMeta('refKey');
  @override
  late final GeneratedColumn<String> refKey = GeneratedColumn<String>(
    'ref_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retriesMeta = const VerificationMeta(
    'retries',
  );
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
    'retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAt = GeneratedColumn<int>(
    'next_attempt_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    endpoint,
    method,
    bodyJson,
    refKey,
    retries,
    lastError,
    createdAt,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('body_json')) {
      context.handle(
        _bodyJsonMeta,
        bodyJson.isAcceptableOrUnknown(data['body_json']!, _bodyJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyJsonMeta);
    }
    if (data.containsKey('ref_key')) {
      context.handle(
        _refKeyMeta,
        refKey.isAcceptableOrUnknown(data['ref_key']!, _refKeyMeta),
      );
    }
    if (data.containsKey('retries')) {
      context.handle(
        _retriesMeta,
        retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      bodyJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_json'],
      )!,
      refKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_key'],
      ),
      retries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retries'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String endpoint;
  final String method;
  final String bodyJson;
  final String? refKey;
  final int retries;
  final String? lastError;
  final int createdAt;
  final int nextAttemptAt;
  const SyncQueueRow({
    required this.id,
    required this.endpoint,
    required this.method,
    required this.bodyJson,
    this.refKey,
    required this.retries,
    this.lastError,
    required this.createdAt,
    required this.nextAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['endpoint'] = Variable<String>(endpoint);
    map['method'] = Variable<String>(method);
    map['body_json'] = Variable<String>(bodyJson);
    if (!nullToAbsent || refKey != null) {
      map['ref_key'] = Variable<String>(refKey);
    }
    map['retries'] = Variable<int>(retries);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['next_attempt_at'] = Variable<int>(nextAttemptAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      endpoint: Value(endpoint),
      method: Value(method),
      bodyJson: Value(bodyJson),
      refKey: refKey == null && nullToAbsent
          ? const Value.absent()
          : Value(refKey),
      retries: Value(retries),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      nextAttemptAt: Value(nextAttemptAt),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      method: serializer.fromJson<String>(json['method']),
      bodyJson: serializer.fromJson<String>(json['bodyJson']),
      refKey: serializer.fromJson<String?>(json['refKey']),
      retries: serializer.fromJson<int>(json['retries']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<int>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'endpoint': serializer.toJson<String>(endpoint),
      'method': serializer.toJson<String>(method),
      'bodyJson': serializer.toJson<String>(bodyJson),
      'refKey': serializer.toJson<String?>(refKey),
      'retries': serializer.toJson<int>(retries),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<int>(createdAt),
      'nextAttemptAt': serializer.toJson<int>(nextAttemptAt),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    String? endpoint,
    String? method,
    String? bodyJson,
    Value<String?> refKey = const Value.absent(),
    int? retries,
    Value<String?> lastError = const Value.absent(),
    int? createdAt,
    int? nextAttemptAt,
  }) => SyncQueueRow(
    id: id ?? this.id,
    endpoint: endpoint ?? this.endpoint,
    method: method ?? this.method,
    bodyJson: bodyJson ?? this.bodyJson,
    refKey: refKey.present ? refKey.value : this.refKey,
    retries: retries ?? this.retries,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      method: data.method.present ? data.method.value : this.method,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      refKey: data.refKey.present ? data.refKey.value : this.refKey,
      retries: data.retries.present ? data.retries.value : this.retries,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('refKey: $refKey, ')
          ..write('retries: $retries, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    endpoint,
    method,
    bodyJson,
    refKey,
    retries,
    lastError,
    createdAt,
    nextAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.endpoint == this.endpoint &&
          other.method == this.method &&
          other.bodyJson == this.bodyJson &&
          other.refKey == this.refKey &&
          other.retries == this.retries &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> endpoint;
  final Value<String> method;
  final Value<String> bodyJson;
  final Value<String?> refKey;
  final Value<int> retries;
  final Value<String?> lastError;
  final Value<int> createdAt;
  final Value<int> nextAttemptAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.method = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.refKey = const Value.absent(),
    this.retries = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String endpoint,
    this.method = const Value.absent(),
    required String bodyJson,
    this.refKey = const Value.absent(),
    this.retries = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAt,
    this.nextAttemptAt = const Value.absent(),
  }) : endpoint = Value(endpoint),
       bodyJson = Value(bodyJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? endpoint,
    Expression<String>? method,
    Expression<String>? bodyJson,
    Expression<String>? refKey,
    Expression<int>? retries,
    Expression<String>? lastError,
    Expression<int>? createdAt,
    Expression<int>? nextAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (bodyJson != null) 'body_json': bodyJson,
      if (refKey != null) 'ref_key': refKey,
      if (retries != null) 'retries': retries,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? endpoint,
    Value<String>? method,
    Value<String>? bodyJson,
    Value<String?>? refKey,
    Value<int>? retries,
    Value<String?>? lastError,
    Value<int>? createdAt,
    Value<int>? nextAttemptAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      bodyJson: bodyJson ?? this.bodyJson,
      refKey: refKey ?? this.refKey,
      retries: retries ?? this.retries,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(bodyJson.value);
    }
    if (refKey.present) {
      map['ref_key'] = Variable<String>(refKey.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<int>(nextAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('refKey: $refKey, ')
          ..write('retries: $retries, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $HeldSalesTable extends HeldSales
    with TableInfo<$HeldSalesTable, HeldSaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeldSalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cartJsonMeta = const VerificationMeta(
    'cartJson',
  );
  @override
  late final GeneratedColumn<String> cartJson = GeneratedColumn<String>(
    'cart_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cartJson, createdAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'held_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeldSaleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cart_json')) {
      context.handle(
        _cartJsonMeta,
        cartJson.isAcceptableOrUnknown(data['cart_json']!, _cartJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_cartJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeldSaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeldSaleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cart_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $HeldSalesTable createAlias(String alias) {
    return $HeldSalesTable(attachedDatabase, alias);
  }
}

class HeldSaleRow extends DataClass implements Insertable<HeldSaleRow> {
  final int id;
  final String cartJson;
  final int createdAt;
  final String? note;
  const HeldSaleRow({
    required this.id,
    required this.cartJson,
    required this.createdAt,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cart_json'] = Variable<String>(cartJson);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  HeldSalesCompanion toCompanion(bool nullToAbsent) {
    return HeldSalesCompanion(
      id: Value(id),
      cartJson: Value(cartJson),
      createdAt: Value(createdAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory HeldSaleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeldSaleRow(
      id: serializer.fromJson<int>(json['id']),
      cartJson: serializer.fromJson<String>(json['cartJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartJson': serializer.toJson<String>(cartJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  HeldSaleRow copyWith({
    int? id,
    String? cartJson,
    int? createdAt,
    Value<String?> note = const Value.absent(),
  }) => HeldSaleRow(
    id: id ?? this.id,
    cartJson: cartJson ?? this.cartJson,
    createdAt: createdAt ?? this.createdAt,
    note: note.present ? note.value : this.note,
  );
  HeldSaleRow copyWithCompanion(HeldSalesCompanion data) {
    return HeldSaleRow(
      id: data.id.present ? data.id.value : this.id,
      cartJson: data.cartJson.present ? data.cartJson.value : this.cartJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeldSaleRow(')
          ..write('id: $id, ')
          ..write('cartJson: $cartJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cartJson, createdAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeldSaleRow &&
          other.id == this.id &&
          other.cartJson == this.cartJson &&
          other.createdAt == this.createdAt &&
          other.note == this.note);
}

class HeldSalesCompanion extends UpdateCompanion<HeldSaleRow> {
  final Value<int> id;
  final Value<String> cartJson;
  final Value<int> createdAt;
  final Value<String?> note;
  const HeldSalesCompanion({
    this.id = const Value.absent(),
    this.cartJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
  });
  HeldSalesCompanion.insert({
    this.id = const Value.absent(),
    required String cartJson,
    required int createdAt,
    this.note = const Value.absent(),
  }) : cartJson = Value(cartJson),
       createdAt = Value(createdAt);
  static Insertable<HeldSaleRow> custom({
    Expression<int>? id,
    Expression<String>? cartJson,
    Expression<int>? createdAt,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartJson != null) 'cart_json': cartJson,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
    });
  }

  HeldSalesCompanion copyWith({
    Value<int>? id,
    Value<String>? cartJson,
    Value<int>? createdAt,
    Value<String?>? note,
  }) {
    return HeldSalesCompanion(
      id: id ?? this.id,
      cartJson: cartJson ?? this.cartJson,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartJson.present) {
      map['cart_json'] = Variable<String>(cartJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeldSalesCompanion(')
          ..write('id: $id, ')
          ..write('cartJson: $cartJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $StockTakeItemsTable extends StockTakeItems
    with TableInfo<$StockTakeItemsTable, StockTakeItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTakeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productSkuMeta = const VerificationMeta(
    'productSku',
  );
  @override
  late final GeneratedColumn<String> productSku = GeneratedColumn<String>(
    'product_sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedQtyMeta = const VerificationMeta(
    'expectedQty',
  );
  @override
  late final GeneratedColumn<double> expectedQty = GeneratedColumn<double>(
    'expected_qty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedQtyMeta = const VerificationMeta(
    'countedQty',
  );
  @override
  late final GeneratedColumn<double> countedQty = GeneratedColumn<double>(
    'counted_qty',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitOfMeasureMeta = const VerificationMeta(
    'unitOfMeasure',
  );
  @override
  late final GeneratedColumn<String> unitOfMeasure = GeneratedColumn<String>(
    'unit_of_measure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unit'),
  );
  static const VerificationMeta _sessionStartedAtMeta = const VerificationMeta(
    'sessionStartedAt',
  );
  @override
  late final GeneratedColumn<int> sessionStartedAt = GeneratedColumn<int>(
    'session_started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    productName,
    productSku,
    expectedQty,
    countedQty,
    unitOfMeasure,
    sessionStartedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_take_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTakeItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_sku')) {
      context.handle(
        _productSkuMeta,
        productSku.isAcceptableOrUnknown(data['product_sku']!, _productSkuMeta),
      );
    } else if (isInserting) {
      context.missing(_productSkuMeta);
    }
    if (data.containsKey('expected_qty')) {
      context.handle(
        _expectedQtyMeta,
        expectedQty.isAcceptableOrUnknown(
          data['expected_qty']!,
          _expectedQtyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedQtyMeta);
    }
    if (data.containsKey('counted_qty')) {
      context.handle(
        _countedQtyMeta,
        countedQty.isAcceptableOrUnknown(data['counted_qty']!, _countedQtyMeta),
      );
    }
    if (data.containsKey('unit_of_measure')) {
      context.handle(
        _unitOfMeasureMeta,
        unitOfMeasure.isAcceptableOrUnknown(
          data['unit_of_measure']!,
          _unitOfMeasureMeta,
        ),
      );
    }
    if (data.containsKey('session_started_at')) {
      context.handle(
        _sessionStartedAtMeta,
        sessionStartedAt.isAcceptableOrUnknown(
          data['session_started_at']!,
          _sessionStartedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionStartedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  StockTakeItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTakeItemRow(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productSku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_sku'],
      )!,
      expectedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_qty'],
      )!,
      countedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}counted_qty'],
      ),
      unitOfMeasure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_of_measure'],
      )!,
      sessionStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_started_at'],
      )!,
    );
  }

  @override
  $StockTakeItemsTable createAlias(String alias) {
    return $StockTakeItemsTable(attachedDatabase, alias);
  }
}

class StockTakeItemRow extends DataClass
    implements Insertable<StockTakeItemRow> {
  final String productId;
  final String productName;
  final String productSku;
  final double expectedQty;
  final double? countedQty;
  final String unitOfMeasure;
  final int sessionStartedAt;
  const StockTakeItemRow({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.expectedQty,
    this.countedQty,
    required this.unitOfMeasure,
    required this.sessionStartedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['product_sku'] = Variable<String>(productSku);
    map['expected_qty'] = Variable<double>(expectedQty);
    if (!nullToAbsent || countedQty != null) {
      map['counted_qty'] = Variable<double>(countedQty);
    }
    map['unit_of_measure'] = Variable<String>(unitOfMeasure);
    map['session_started_at'] = Variable<int>(sessionStartedAt);
    return map;
  }

  StockTakeItemsCompanion toCompanion(bool nullToAbsent) {
    return StockTakeItemsCompanion(
      productId: Value(productId),
      productName: Value(productName),
      productSku: Value(productSku),
      expectedQty: Value(expectedQty),
      countedQty: countedQty == null && nullToAbsent
          ? const Value.absent()
          : Value(countedQty),
      unitOfMeasure: Value(unitOfMeasure),
      sessionStartedAt: Value(sessionStartedAt),
    );
  }

  factory StockTakeItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTakeItemRow(
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      productSku: serializer.fromJson<String>(json['productSku']),
      expectedQty: serializer.fromJson<double>(json['expectedQty']),
      countedQty: serializer.fromJson<double?>(json['countedQty']),
      unitOfMeasure: serializer.fromJson<String>(json['unitOfMeasure']),
      sessionStartedAt: serializer.fromJson<int>(json['sessionStartedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'productSku': serializer.toJson<String>(productSku),
      'expectedQty': serializer.toJson<double>(expectedQty),
      'countedQty': serializer.toJson<double?>(countedQty),
      'unitOfMeasure': serializer.toJson<String>(unitOfMeasure),
      'sessionStartedAt': serializer.toJson<int>(sessionStartedAt),
    };
  }

  StockTakeItemRow copyWith({
    String? productId,
    String? productName,
    String? productSku,
    double? expectedQty,
    Value<double?> countedQty = const Value.absent(),
    String? unitOfMeasure,
    int? sessionStartedAt,
  }) => StockTakeItemRow(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    productSku: productSku ?? this.productSku,
    expectedQty: expectedQty ?? this.expectedQty,
    countedQty: countedQty.present ? countedQty.value : this.countedQty,
    unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
    sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
  );
  StockTakeItemRow copyWithCompanion(StockTakeItemsCompanion data) {
    return StockTakeItemRow(
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productSku: data.productSku.present
          ? data.productSku.value
          : this.productSku,
      expectedQty: data.expectedQty.present
          ? data.expectedQty.value
          : this.expectedQty,
      countedQty: data.countedQty.present
          ? data.countedQty.value
          : this.countedQty,
      unitOfMeasure: data.unitOfMeasure.present
          ? data.unitOfMeasure.value
          : this.unitOfMeasure,
      sessionStartedAt: data.sessionStartedAt.present
          ? data.sessionStartedAt.value
          : this.sessionStartedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTakeItemRow(')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('countedQty: $countedQty, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('sessionStartedAt: $sessionStartedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productId,
    productName,
    productSku,
    expectedQty,
    countedQty,
    unitOfMeasure,
    sessionStartedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTakeItemRow &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.productSku == this.productSku &&
          other.expectedQty == this.expectedQty &&
          other.countedQty == this.countedQty &&
          other.unitOfMeasure == this.unitOfMeasure &&
          other.sessionStartedAt == this.sessionStartedAt);
}

class StockTakeItemsCompanion extends UpdateCompanion<StockTakeItemRow> {
  final Value<String> productId;
  final Value<String> productName;
  final Value<String> productSku;
  final Value<double> expectedQty;
  final Value<double?> countedQty;
  final Value<String> unitOfMeasure;
  final Value<int> sessionStartedAt;
  final Value<int> rowid;
  const StockTakeItemsCompanion({
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.productSku = const Value.absent(),
    this.expectedQty = const Value.absent(),
    this.countedQty = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.sessionStartedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTakeItemsCompanion.insert({
    required String productId,
    required String productName,
    required String productSku,
    required double expectedQty,
    this.countedQty = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    required int sessionStartedAt,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       productName = Value(productName),
       productSku = Value(productSku),
       expectedQty = Value(expectedQty),
       sessionStartedAt = Value(sessionStartedAt);
  static Insertable<StockTakeItemRow> custom({
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? productSku,
    Expression<double>? expectedQty,
    Expression<double>? countedQty,
    Expression<String>? unitOfMeasure,
    Expression<int>? sessionStartedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (productSku != null) 'product_sku': productSku,
      if (expectedQty != null) 'expected_qty': expectedQty,
      if (countedQty != null) 'counted_qty': countedQty,
      if (unitOfMeasure != null) 'unit_of_measure': unitOfMeasure,
      if (sessionStartedAt != null) 'session_started_at': sessionStartedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTakeItemsCompanion copyWith({
    Value<String>? productId,
    Value<String>? productName,
    Value<String>? productSku,
    Value<double>? expectedQty,
    Value<double?>? countedQty,
    Value<String>? unitOfMeasure,
    Value<int>? sessionStartedAt,
    Value<int>? rowid,
  }) {
    return StockTakeItemsCompanion(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      expectedQty: expectedQty ?? this.expectedQty,
      countedQty: countedQty ?? this.countedQty,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productSku.present) {
      map['product_sku'] = Variable<String>(productSku.value);
    }
    if (expectedQty.present) {
      map['expected_qty'] = Variable<double>(expectedQty.value);
    }
    if (countedQty.present) {
      map['counted_qty'] = Variable<double>(countedQty.value);
    }
    if (unitOfMeasure.present) {
      map['unit_of_measure'] = Variable<String>(unitOfMeasure.value);
    }
    if (sessionStartedAt.present) {
      map['session_started_at'] = Variable<int>(sessionStartedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTakeItemsCompanion(')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('productSku: $productSku, ')
          ..write('expectedQty: $expectedQty, ')
          ..write('countedQty: $countedQty, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('sessionStartedAt: $sessionStartedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<double> delta = GeneratedColumn<double>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousStockMeta = const VerificationMeta(
    'previousStock',
  );
  @override
  late final GeneratedColumn<double> previousStock = GeneratedColumn<double>(
    'previous_stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStockMeta = const VerificationMeta(
    'newStock',
  );
  @override
  late final GeneratedColumn<double> newStock = GeneratedColumn<double>(
    'new_stock',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<int> synced = GeneratedColumn<int>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    productName,
    delta,
    previousStock,
    newStock,
    reason,
    createdAt,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('previous_stock')) {
      context.handle(
        _previousStockMeta,
        previousStock.isAcceptableOrUnknown(
          data['previous_stock']!,
          _previousStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStockMeta);
    }
    if (data.containsKey('new_stock')) {
      context.handle(
        _newStockMeta,
        newStock.isAcceptableOrUnknown(data['new_stock']!, _newStockMeta),
      );
    } else if (isInserting) {
      context.missing(_newStockMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delta'],
      )!,
      previousStock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_stock'],
      )!,
      newStock: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_stock'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final int id;
  final String productId;
  final String productName;
  final double delta;
  final double previousStock;
  final double newStock;
  final String reason;
  final int createdAt;
  final int synced;
  const StockMovementRow({
    required this.id,
    required this.productId,
    required this.productName,
    required this.delta,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    required this.createdAt,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['delta'] = Variable<double>(delta);
    map['previous_stock'] = Variable<double>(previousStock);
    map['new_stock'] = Variable<double>(newStock);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<int>(createdAt);
    map['synced'] = Variable<int>(synced);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      productName: Value(productName),
      delta: Value(delta),
      previousStock: Value(previousStock),
      newStock: Value(newStock),
      reason: Value(reason),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory StockMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      delta: serializer.fromJson<double>(json['delta']),
      previousStock: serializer.fromJson<double>(json['previousStock']),
      newStock: serializer.fromJson<double>(json['newStock']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      synced: serializer.fromJson<int>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'delta': serializer.toJson<double>(delta),
      'previousStock': serializer.toJson<double>(previousStock),
      'newStock': serializer.toJson<double>(newStock),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<int>(createdAt),
      'synced': serializer.toJson<int>(synced),
    };
  }

  StockMovementRow copyWith({
    int? id,
    String? productId,
    String? productName,
    double? delta,
    double? previousStock,
    double? newStock,
    String? reason,
    int? createdAt,
    int? synced,
  }) => StockMovementRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    delta: delta ?? this.delta,
    previousStock: previousStock ?? this.previousStock,
    newStock: newStock ?? this.newStock,
    reason: reason ?? this.reason,
    createdAt: createdAt ?? this.createdAt,
    synced: synced ?? this.synced,
  );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      delta: data.delta.present ? data.delta.value : this.delta,
      previousStock: data.previousStock.present
          ? data.previousStock.value
          : this.previousStock,
      newStock: data.newStock.present ? data.newStock.value : this.newStock,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('delta: $delta, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    productName,
    delta,
    previousStock,
    newStock,
    reason,
    createdAt,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.delta == this.delta &&
          other.previousStock == this.previousStock &&
          other.newStock == this.newStock &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<int> id;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> delta;
  final Value<double> previousStock;
  final Value<double> newStock;
  final Value<String> reason;
  final Value<int> createdAt;
  final Value<int> synced;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.delta = const Value.absent(),
    this.previousStock = const Value.absent(),
    this.newStock = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required String productId,
    required String productName,
    required double delta,
    required double previousStock,
    required double newStock,
    required String reason,
    required int createdAt,
    this.synced = const Value.absent(),
  }) : productId = Value(productId),
       productName = Value(productName),
       delta = Value(delta),
       previousStock = Value(previousStock),
       newStock = Value(newStock),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<StockMovementRow> custom({
    Expression<int>? id,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? delta,
    Expression<double>? previousStock,
    Expression<double>? newStock,
    Expression<String>? reason,
    Expression<int>? createdAt,
    Expression<int>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (delta != null) 'delta': delta,
      if (previousStock != null) 'previous_stock': previousStock,
      if (newStock != null) 'new_stock': newStock,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
    });
  }

  StockMovementsCompanion copyWith({
    Value<int>? id,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? delta,
    Value<double>? previousStock,
    Value<double>? newStock,
    Value<String>? reason,
    Value<int>? createdAt,
    Value<int>? synced,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      delta: delta ?? this.delta,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (delta.present) {
      map['delta'] = Variable<double>(delta.value);
    }
    if (previousStock.present) {
      map['previous_stock'] = Variable<double>(previousStock.value);
    }
    if (newStock.present) {
      map['new_stock'] = Variable<double>(newStock.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<int>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('delta: $delta, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SettingsKvTable settingsKv = $SettingsKvTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $HeldSalesTable heldSales = $HeldSalesTable(this);
  late final $StockTakeItemsTable stockTakeItems = $StockTakeItemsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    categories,
    customers,
    settingsKv,
    sales,
    syncQueue,
    heldSales,
    stockTakeItems,
    stockMovements,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      required String sku,
      Value<String?> barcode,
      Value<String?> categoryId,
      required double price,
      Value<double?> costPrice,
      required double stock,
      Value<String> status,
      Value<String> description,
      Value<String> unitOfMeasure,
      Value<String> imageUrlsJson,
      Value<String?> brand,
      Value<double?> reorderPoint,
      Value<int?> unitsPerBox,
      Value<double?> boxCost,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> sku,
      Value<String?> barcode,
      Value<String?> categoryId,
      Value<double> price,
      Value<double?> costPrice,
      Value<double> stock,
      Value<String> status,
      Value<String> description,
      Value<String> unitOfMeasure,
      Value<String> imageUrlsJson,
      Value<String?> brand,
      Value<double?> reorderPoint,
      Value<int?> unitsPerBox,
      Value<double?> boxCost,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get boxCost => $composableBuilder(
    column: $table.boxCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get boxCost => $composableBuilder(
    column: $table.boxCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrlsJson => $composableBuilder(
    column: $table.imageUrlsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get reorderPoint => $composableBuilder(
    column: $table.reorderPoint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitsPerBox => $composableBuilder(
    column: $table.unitsPerBox,
    builder: (column) => column,
  );

  GeneratedColumn<double> get boxCost =>
      $composableBuilder(column: $table.boxCost, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (
            ProductRow,
            BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>,
          ),
          ProductRow,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> costPrice = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                Value<String> imageUrlsJson = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> reorderPoint = const Value.absent(),
                Value<int?> unitsPerBox = const Value.absent(),
                Value<double?> boxCost = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                categoryId: categoryId,
                price: price,
                costPrice: costPrice,
                stock: stock,
                status: status,
                description: description,
                unitOfMeasure: unitOfMeasure,
                imageUrlsJson: imageUrlsJson,
                brand: brand,
                reorderPoint: reorderPoint,
                unitsPerBox: unitsPerBox,
                boxCost: boxCost,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String sku,
                Value<String?> barcode = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                required double price,
                Value<double?> costPrice = const Value.absent(),
                required double stock,
                Value<String> status = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                Value<String> imageUrlsJson = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> reorderPoint = const Value.absent(),
                Value<int?> unitsPerBox = const Value.absent(),
                Value<double?> boxCost = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                categoryId: categoryId,
                price: price,
                costPrice: costPrice,
                stock: stock,
                status: status,
                description: description,
                unitOfMeasure: unitOfMeasure,
                imageUrlsJson: imageUrlsJson,
                brand: brand,
                reorderPoint: reorderPoint,
                unitsPerBox: unitsPerBox,
                boxCost: boxCost,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
      ProductRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String name,
      Value<String?> email,
      Value<String?> phone,
      Value<double> storeCredit,
      Value<double> accountBalance,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> phone,
      Value<double> storeCredit,
      Value<double> accountBalance,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get storeCredit => $composableBuilder(
    column: $table.storeCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get storeCredit => $composableBuilder(
    column: $table.storeCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get storeCredit => $composableBuilder(
    column: $table.storeCredit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accountBalance => $composableBuilder(
    column: $table.accountBalance,
    builder: (column) => column,
  );
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerRow,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
          ),
          CustomerRow,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double> storeCredit = const Value.absent(),
                Value<double> accountBalance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                email: email,
                phone: phone,
                storeCredit: storeCredit,
                accountBalance: accountBalance,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<double> storeCredit = const Value.absent(),
                Value<double> accountBalance = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                email: email,
                phone: phone,
                storeCredit: storeCredit,
                accountBalance: accountBalance,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerRow,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
      ),
      CustomerRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsKvTableCreateCompanionBuilder =
    SettingsKvCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsKvTableUpdateCompanionBuilder =
    SettingsKvCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsKvTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsKvTable> {
  $$SettingsKvTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsKvTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsKvTable> {
  $$SettingsKvTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsKvTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsKvTable> {
  $$SettingsKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsKvTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsKvTable,
          SettingsRow,
          $$SettingsKvTableFilterComposer,
          $$SettingsKvTableOrderingComposer,
          $$SettingsKvTableAnnotationComposer,
          $$SettingsKvTableCreateCompanionBuilder,
          $$SettingsKvTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsKvTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsKvTableTableManager(_$AppDatabase db, $SettingsKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsKvCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsKvCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsKvTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsKvTable,
      SettingsRow,
      $$SettingsKvTableFilterComposer,
      $$SettingsKvTableOrderingComposer,
      $$SettingsKvTableAnnotationComposer,
      $$SettingsKvTableCreateCompanionBuilder,
      $$SettingsKvTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $SettingsKvTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String transactionId,
      required String timestamp,
      required String payloadJson,
      required double total,
      Value<String?> customerName,
      Value<int> synced,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> transactionId,
      Value<String> timestamp,
      Value<String> payloadJson,
      Value<double> total,
      Value<String?> customerName,
      Value<int> synced,
      Value<int> rowid,
    });

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleRow,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
          SaleRow,
          PrefetchHooks Function()
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transactionId = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<int> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                transactionId: transactionId,
                timestamp: timestamp,
                payloadJson: payloadJson,
                total: total,
                customerName: customerName,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transactionId,
                required String timestamp,
                required String payloadJson,
                required double total,
                Value<String?> customerName = const Value.absent(),
                Value<int> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                transactionId: transactionId,
                timestamp: timestamp,
                payloadJson: payloadJson,
                total: total,
                customerName: customerName,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleRow,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
      SaleRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String endpoint,
      Value<String> method,
      required String bodyJson,
      Value<String?> refKey,
      Value<int> retries,
      Value<String?> lastError,
      required int createdAt,
      Value<int> nextAttemptAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> endpoint,
      Value<String> method,
      Value<String> bodyJson,
      Value<String?> refKey,
      Value<int> retries,
      Value<String?> lastError,
      Value<int> createdAt,
      Value<int> nextAttemptAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyJson => $composableBuilder(
    column: $table.bodyJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refKey => $composableBuilder(
    column: $table.refKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyJson => $composableBuilder(
    column: $table.bodyJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refKey => $composableBuilder(
    column: $table.refKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<String> get refKey =>
      $composableBuilder(column: $table.refKey, builder: (column) => column);

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> bodyJson = const Value.absent(),
                Value<String?> refKey = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> nextAttemptAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                endpoint: endpoint,
                method: method,
                bodyJson: bodyJson,
                refKey: refKey,
                retries: retries,
                lastError: lastError,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String endpoint,
                Value<String> method = const Value.absent(),
                required String bodyJson,
                Value<String?> refKey = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAt,
                Value<int> nextAttemptAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                endpoint: endpoint,
                method: method,
                bodyJson: bodyJson,
                refKey: refKey,
                retries: retries,
                lastError: lastError,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$HeldSalesTableCreateCompanionBuilder =
    HeldSalesCompanion Function({
      Value<int> id,
      required String cartJson,
      required int createdAt,
      Value<String?> note,
    });
typedef $$HeldSalesTableUpdateCompanionBuilder =
    HeldSalesCompanion Function({
      Value<int> id,
      Value<String> cartJson,
      Value<int> createdAt,
      Value<String?> note,
    });

class $$HeldSalesTableFilterComposer
    extends Composer<_$AppDatabase, $HeldSalesTable> {
  $$HeldSalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cartJson => $composableBuilder(
    column: $table.cartJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeldSalesTableOrderingComposer
    extends Composer<_$AppDatabase, $HeldSalesTable> {
  $$HeldSalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cartJson => $composableBuilder(
    column: $table.cartJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeldSalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeldSalesTable> {
  $$HeldSalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cartJson =>
      $composableBuilder(column: $table.cartJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$HeldSalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeldSalesTable,
          HeldSaleRow,
          $$HeldSalesTableFilterComposer,
          $$HeldSalesTableOrderingComposer,
          $$HeldSalesTableAnnotationComposer,
          $$HeldSalesTableCreateCompanionBuilder,
          $$HeldSalesTableUpdateCompanionBuilder,
          (
            HeldSaleRow,
            BaseReferences<_$AppDatabase, $HeldSalesTable, HeldSaleRow>,
          ),
          HeldSaleRow,
          PrefetchHooks Function()
        > {
  $$HeldSalesTableTableManager(_$AppDatabase db, $HeldSalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeldSalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeldSalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeldSalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cartJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => HeldSalesCompanion(
                id: id,
                cartJson: cartJson,
                createdAt: createdAt,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cartJson,
                required int createdAt,
                Value<String?> note = const Value.absent(),
              }) => HeldSalesCompanion.insert(
                id: id,
                cartJson: cartJson,
                createdAt: createdAt,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeldSalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeldSalesTable,
      HeldSaleRow,
      $$HeldSalesTableFilterComposer,
      $$HeldSalesTableOrderingComposer,
      $$HeldSalesTableAnnotationComposer,
      $$HeldSalesTableCreateCompanionBuilder,
      $$HeldSalesTableUpdateCompanionBuilder,
      (
        HeldSaleRow,
        BaseReferences<_$AppDatabase, $HeldSalesTable, HeldSaleRow>,
      ),
      HeldSaleRow,
      PrefetchHooks Function()
    >;
typedef $$StockTakeItemsTableCreateCompanionBuilder =
    StockTakeItemsCompanion Function({
      required String productId,
      required String productName,
      required String productSku,
      required double expectedQty,
      Value<double?> countedQty,
      Value<String> unitOfMeasure,
      required int sessionStartedAt,
      Value<int> rowid,
    });
typedef $$StockTakeItemsTableUpdateCompanionBuilder =
    StockTakeItemsCompanion Function({
      Value<String> productId,
      Value<String> productName,
      Value<String> productSku,
      Value<double> expectedQty,
      Value<double?> countedQty,
      Value<String> unitOfMeasure,
      Value<int> sessionStartedAt,
      Value<int> rowid,
    });

class $$StockTakeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StockTakeItemsTable> {
  $$StockTakeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedQty => $composableBuilder(
    column: $table.expectedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get countedQty => $composableBuilder(
    column: $table.countedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockTakeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTakeItemsTable> {
  $$StockTakeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedQty => $composableBuilder(
    column: $table.expectedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get countedQty => $composableBuilder(
    column: $table.countedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockTakeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTakeItemsTable> {
  $$StockTakeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productSku => $composableBuilder(
    column: $table.productSku,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedQty => $composableBuilder(
    column: $table.expectedQty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get countedQty => $composableBuilder(
    column: $table.countedQty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitOfMeasure => $composableBuilder(
    column: $table.unitOfMeasure,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionStartedAt => $composableBuilder(
    column: $table.sessionStartedAt,
    builder: (column) => column,
  );
}

class $$StockTakeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTakeItemsTable,
          StockTakeItemRow,
          $$StockTakeItemsTableFilterComposer,
          $$StockTakeItemsTableOrderingComposer,
          $$StockTakeItemsTableAnnotationComposer,
          $$StockTakeItemsTableCreateCompanionBuilder,
          $$StockTakeItemsTableUpdateCompanionBuilder,
          (
            StockTakeItemRow,
            BaseReferences<
              _$AppDatabase,
              $StockTakeItemsTable,
              StockTakeItemRow
            >,
          ),
          StockTakeItemRow,
          PrefetchHooks Function()
        > {
  $$StockTakeItemsTableTableManager(
    _$AppDatabase db,
    $StockTakeItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTakeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTakeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTakeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> productSku = const Value.absent(),
                Value<double> expectedQty = const Value.absent(),
                Value<double?> countedQty = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                Value<int> sessionStartedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTakeItemsCompanion(
                productId: productId,
                productName: productName,
                productSku: productSku,
                expectedQty: expectedQty,
                countedQty: countedQty,
                unitOfMeasure: unitOfMeasure,
                sessionStartedAt: sessionStartedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required String productName,
                required String productSku,
                required double expectedQty,
                Value<double?> countedQty = const Value.absent(),
                Value<String> unitOfMeasure = const Value.absent(),
                required int sessionStartedAt,
                Value<int> rowid = const Value.absent(),
              }) => StockTakeItemsCompanion.insert(
                productId: productId,
                productName: productName,
                productSku: productSku,
                expectedQty: expectedQty,
                countedQty: countedQty,
                unitOfMeasure: unitOfMeasure,
                sessionStartedAt: sessionStartedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockTakeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTakeItemsTable,
      StockTakeItemRow,
      $$StockTakeItemsTableFilterComposer,
      $$StockTakeItemsTableOrderingComposer,
      $$StockTakeItemsTableAnnotationComposer,
      $$StockTakeItemsTableCreateCompanionBuilder,
      $$StockTakeItemsTableUpdateCompanionBuilder,
      (
        StockTakeItemRow,
        BaseReferences<_$AppDatabase, $StockTakeItemsTable, StockTakeItemRow>,
      ),
      StockTakeItemRow,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      required String productId,
      required String productName,
      required double delta,
      required double previousStock,
      required double newStock,
      required String reason,
      required int createdAt,
      Value<int> synced,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      Value<String> productId,
      Value<String> productName,
      Value<double> delta,
      Value<double> previousStock,
      Value<double> newStock,
      Value<String> reason,
      Value<int> createdAt,
      Value<int> synced,
    });

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<double> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newStock =>
      $composableBuilder(column: $table.newStock, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovementRow,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (
            StockMovementRow,
            BaseReferences<
              _$AppDatabase,
              $StockMovementsTable,
              StockMovementRow
            >,
          ),
          StockMovementRow,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> delta = const Value.absent(),
                Value<double> previousStock = const Value.absent(),
                Value<double> newStock = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> synced = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                productName: productName,
                delta: delta,
                previousStock: previousStock,
                newStock: newStock,
                reason: reason,
                createdAt: createdAt,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String productId,
                required String productName,
                required double delta,
                required double previousStock,
                required double newStock,
                required String reason,
                required int createdAt,
                Value<int> synced = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                productName: productName,
                delta: delta,
                previousStock: previousStock,
                newStock: newStock,
                reason: reason,
                createdAt: createdAt,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovementRow,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (
        StockMovementRow,
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>,
      ),
      StockMovementRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SettingsKvTableTableManager get settingsKv =>
      $$SettingsKvTableTableManager(_db, _db.settingsKv);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$HeldSalesTableTableManager get heldSales =>
      $$HeldSalesTableTableManager(_db, _db.heldSales);
  $$StockTakeItemsTableTableManager get stockTakeItems =>
      $$StockTakeItemsTableTableManager(_db, _db.stockTakeItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
}
