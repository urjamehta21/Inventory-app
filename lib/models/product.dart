// lib/models/product.dart
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double quantity;

  @HiveField(4)
  double minimumThreshold;

  @HiveField(5)
  String unit;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  String? description;

  @HiveField(9)
  double? costPrice;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimumThreshold,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.costPrice,
  });

  StockStatus get stockStatus {
    if (quantity <= 0) return StockStatus.outOfStock;
    if (quantity <= minimumThreshold) return StockStatus.low;
    if (quantity <= minimumThreshold * 1.5) return StockStatus.warning;
    return StockStatus.normal;
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    double? minimumThreshold,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    double? costPrice,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minimumThreshold: minimumThreshold ?? this.minimumThreshold,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      costPrice: costPrice ?? this.costPrice,
    );
  }
}

enum StockStatus { normal, warning, low, outOfStock }
