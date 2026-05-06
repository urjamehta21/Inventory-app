// lib/providers/inventory_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/stock_log.dart';
import '../services/inventory_service.dart';

// Service provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  return InventoryService();
});

// Products notifier
class ProductsNotifier extends StateNotifier<List<Product>> {
  final InventoryService _service;

  ProductsNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getAllProducts();
  }

  Future<void> reload() async {
    state = _service.getAllProducts();
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
    final p = await _service.createProduct(
      name: name,
      category: category,
      quantity: quantity,
      minimumThreshold: minimumThreshold,
      unit: unit,
      description: description,
      costPrice: costPrice,
    );
    _load();
    return p;
  }

  Future<Product> updateProduct(Product product) async {
    final p = await _service.updateProduct(product);
    _load();
    return p;
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    _load();
  }

  Future<StockLog> stockIn(String productId, double qty, {String? note}) async {
    final log = await _service.stockIn(productId: productId, quantity: qty, note: note);
    _load();
    return log;
  }

  Future<StockLog> stockOut(String productId, double qty, {String? note}) async {
    final log = await _service.stockOut(productId: productId, quantity: qty, note: note);
    _load();
    return log;
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier(ref.read(inventoryServiceProvider));
});

// Logs notifier
class LogsNotifier extends StateNotifier<List<StockLog>> {
  final InventoryService _service;

  LogsNotifier(this._service) : super([]) {
    _load();
  }

  void _load() {
    state = _service.getAllLogs();
  }

  void reload() {
    state = _service.getAllLogs();
  }

  List<StockLog> getForProduct(String productId) {
    return _service.getLogsForProduct(productId);
  }
}

final logsProvider = StateNotifierProvider<LogsNotifier, List<StockLog>>((ref) {
  // Listen to product changes and refresh logs
  ref.listen(productsProvider, (_, __) {
    ref.notifier.reload();
  });
  return LogsNotifier(ref.read(inventoryServiceProvider));
});

// Dashboard stats
final dashboardStatsProvider = Provider<Map<String, dynamic>>((ref) {
  ref.watch(productsProvider);
  return ref.read(inventoryServiceProvider).getDashboardStats();
});

// Categories
final categoriesProvider = Provider<List<String>>((ref) {
  ref.watch(productsProvider);
  return ref.read(inventoryServiceProvider).getCategories();
});

// Search/filter state
class SearchFilterState {
  final String query;
  final String? category;
  final StockStatus? status;

  const SearchFilterState({
    this.query = '',
    this.category,
    this.status,
  });

  SearchFilterState copyWith({
    String? query,
    String? category,
    StockStatus? status,
    bool clearCategory = false,
    bool clearStatus = false,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  final InventoryService _service;

  SearchFilterNotifier(this._service) : super(const SearchFilterState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(String? c) => state = c == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: c);
  void setStatus(StockStatus? s) => state = s == null
      ? state.copyWith(clearStatus: true)
      : state.copyWith(status: s);
  void clearAll() => state = const SearchFilterState();

  List<Product> get filteredProducts => _service.searchAndFilter(
    query: state.query,
    category: state.category,
    status: state.status,
  );
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
  // Rebuild when products change
  ref.watch(productsProvider);
  return SearchFilterNotifier(ref.read(inventoryServiceProvider));
});

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final notifier = ref.watch(searchFilterProvider.notifier);
  ref.watch(searchFilterProvider);
  ref.watch(productsProvider);
  return notifier.filteredProducts;
});

// Low stock alerts count
final lowStockCountProvider = Provider<int>((ref) {
  final products = ref.watch(productsProvider);
  return products
      .where((p) => p.stockStatus == StockStatus.low ||
          p.stockStatus == StockStatus.warning ||
          p.stockStatus == StockStatus.outOfStock)
      .length;
});
