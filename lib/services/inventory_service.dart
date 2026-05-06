// lib/services/inventory_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/stock_log.dart';

class InventoryService {
  static const String _productsBox = 'products';
  static const String _logsBox = 'stock_logs';
  static const _uuid = Uuid();

  Box<Product> get _products => Hive.box<Product>(_productsBox);
  Box<StockLog> get _logs => Hive.box<StockLog>(_logsBox);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(StockLogAdapter());
    Hive.registerAdapter(StockLogTypeAdapter());
    await Hive.openBox<Product>(_productsBox);
    await Hive.openBox<StockLog>(_logsBox);
  }

  // Products
  List<Product> getAllProducts() {
    return _products.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Product? getProduct(String id) {
    return _products.values.firstWhere((p) => p.id == id, orElse: () => throw Exception('Not found'));
  }

  Future<Product> addProduct(Product product) async {
    await _products.put(product.id, product);
    return product;
  }

  Future<Product> createProduct({
    required String name,
    required String category,
    required double quantity,
    required double minimumThreshold,
    required String unit,
    String? description,
    double? costPrice,
  }) async {
    final now = DateTime.now();
    final product = Product(
      id: _uuid.v4(),
      name: name,
      category: category,
      quantity: quantity,
      minimumThreshold: minimumThreshold,
      unit: unit,
      createdAt: now,
      updatedAt: now,
      description: description,
      costPrice: costPrice,
    );
    await _products.put(product.id, product);
    // Log initial stock if > 0
    if (quantity > 0) {
      await _addLog(
        productId: product.id,
        productName: product.name,
        type: StockLogType.stockIn,
        quantity: quantity,
        before: 0,
        after: quantity,
        note: 'Initial stock',
      );
    }
    return product;
  }

  Future<Product> updateProduct(Product product) async {
    final updated = product.copyWith(updatedAt: DateTime.now());
    await _products.put(updated.id, updated);
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    await _products.delete(id);
  }

  // Stock Updates
  Future<StockLog> stockIn({
    required String productId,
    required double quantity,
    String? note,
  }) async {
    final product = _products.get(productId);
    if (product == null) throw Exception('Product not found');
    if (quantity <= 0) throw Exception('Quantity must be greater than 0');

    final before = product.quantity;
    final after = before + quantity;
    final updated = product.copyWith(quantity: after, updatedAt: DateTime.now());
    await _products.put(productId, updated);

    return _addLog(
      productId: productId,
      productName: product.name,
      type: StockLogType.stockIn,
      quantity: quantity,
      before: before,
      after: after,
      note: note,
    );
  }

  Future<StockLog> stockOut({
    required String productId,
    required double quantity,
    String? note,
  }) async {
    final product = _products.get(productId);
    if (product == null) throw Exception('Product not found');
    if (quantity <= 0) throw Exception('Quantity must be greater than 0');
    if (quantity > product.quantity) {
      throw Exception('Insufficient stock. Available: ${product.quantity} ${product.unit}');
    }

    final before = product.quantity;
    final after = before - quantity;
    final updated = product.copyWith(quantity: after, updatedAt: DateTime.now());
    await _products.put(productId, updated);

    return _addLog(
      productId: productId,
      productName: product.name,
      type: StockLogType.stockOut,
      quantity: quantity,
      before: before,
      after: after,
      note: note,
    );
  }

  Future<StockLog> _addLog({
    required String productId,
    required String productName,
    required StockLogType type,
    required double quantity,
    required double before,
    required double after,
    String? note,
  }) async {
    final log = StockLog(
      id: _uuid.v4(),
      productId: productId,
      productName: productName,
      type: type,
      quantity: quantity,
      quantityBefore: before,
      quantityAfter: after,
      timestamp: DateTime.now(),
      note: note,
    );
    await _logs.put(log.id, log);
    return log;
  }

  // Logs
  List<StockLog> getAllLogs() {
    return _logs.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<StockLog> getLogsForProduct(String productId) {
    return _logs.values
        .where((l) => l.productId == productId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Stats
  Map<String, dynamic> getDashboardStats() {
    final products = getAllProducts();
    final lowStock = products.where((p) =>
        p.stockStatus == StockStatus.low ||
        p.stockStatus == StockStatus.warning).toList();
    final outOfStock = products.where((p) => p.stockStatus == StockStatus.outOfStock).toList();
    final recentLogs = getAllLogs().take(10).toList();

    return {
      'totalProducts': products.length,
      'lowStockCount': lowStock.length,
      'outOfStockCount': outOfStock.length,
      'lowStockItems': lowStock,
      'recentLogs': recentLogs,
      'recentlyUpdated': products.take(5).toList(),
    };
  }

  List<String> getCategories() {
    final cats = _products.values.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  // Search & Filter
  List<Product> searchAndFilter({
    String? query,
    String? category,
    StockStatus? status,
  }) {
    var products = getAllProducts();

    if (query != null && query.isNotEmpty) {
      products = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (category != null && category.isNotEmpty) {
      products = products.where((p) => p.category == category).toList();
    }
    if (status != null) {
      products = products.where((p) => p.stockStatus == status).toList();
    }
    return products;
  }

  // Seeding demo data
  Future<void> seedDemoData() async {
    if (_products.isNotEmpty) return;

    final demoProducts = [
      ('Paracetamol 500mg', 'Medicine', 250.0, 50.0, 'tablets'),
      ('Hand Sanitizer', 'Hygiene', 15.0, 20.0, 'bottles'),
      ('A4 Paper Ream', 'Stationery', 8.0, 10.0, 'reams'),
      ('Coffee Beans', 'Pantry', 3.0, 5.0, 'kg'),
      ('Printer Ink - Black', 'Office', 0.0, 2.0, 'units'),
      ('Notebook A5', 'Stationery', 45.0, 15.0, 'pcs'),
      ('Surgical Gloves', 'Medicine', 120.0, 100.0, 'pairs'),
      ('USB Cables', 'Electronics', 12.0, 5.0, 'pcs'),
    ];

    for (final (name, cat, qty, min, unit) in demoProducts) {
      await createProduct(
        name: name,
        category: cat,
        quantity: qty,
        minimumThreshold: min,
        unit: unit,
      );
    }
  }
}
