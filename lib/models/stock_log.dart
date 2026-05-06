// lib/models/stock_log.dart
import 'package:hive/hive.dart';

part 'stock_log.g.dart';

@HiveType(typeId: 1)
class StockLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productId;

  @HiveField(2)
  String productName;

  @HiveField(3)
  StockLogType type;

  @HiveField(4)
  double quantity;

  @HiveField(5)
  double quantityBefore;

  @HiveField(6)
  double quantityAfter;

  @HiveField(7)
  DateTime timestamp;

  @HiveField(8)
  String? note;

  @HiveField(9)
  bool synced;

  StockLog({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.timestamp,
    this.note,
    this.synced = false,
  });
}

@HiveType(typeId: 2)
enum StockLogType {
  @HiveField(0)
  stockIn,
  @HiveField(1)
  stockOut,
  @HiveField(2)
  adjustment,
}
