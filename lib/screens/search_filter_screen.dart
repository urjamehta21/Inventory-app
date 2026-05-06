// lib/screens/search_filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';
import 'stock_update_screen.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterProvider);
    final filtered = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final hasActiveFilters = filterState.query.isNotEmpty ||
        filterState.category != null ||
        filterState.status != null;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Search & Filter'),
        actions: [
          if (hasActiveFilters)
            TextButton(
              onPressed: () {
                ref.read(searchFilterProvider.notifier).clearAll();
                _searchCtrl.clear();
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppTheme.accentOrange, fontFamily: 'Sora', fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              autofocus: false,
              onChanged: (q) => ref.read(searchFilterProvider.notifier).setQuery(q),
              style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora'),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                suffixIcon: filterState.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(searchFilterProvider.notifier).setQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _showFilters || hasActiveFilters
                          ? AppTheme.accent.withOpacity(0.15)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _showFilters || hasActiveFilters
                            ? AppTheme.accent.withOpacity(0.4)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 16,
                          color: _showFilters || hasActiveFilters
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: _showFilters || hasActiveFilters
                                ? AppTheme.accent
                                : AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Sora',
                          ),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${(filterState.category != null ? 1 : 0) + (filterState.status != null ? 1 : 0)}',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Sora',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${filtered.length} products',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: 'Sora'),
                ),
              ],
            ),
          ),

          // Filters panel
          if (_showFilters) _FiltersPanel(categories: categories),

          // Results
          Expanded(
            child: filtered.isEmpty
                ? _EmptyResults(hasQuery: filterState.query.isNotEmpty || hasActiveFilters)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final product = filtered[i];
                      return ProductCard(
                        product: product,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditProductScreen(product: product),
                          ),
                        ),
                        onStockUpdate: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockUpdateScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends ConsumerWidget {
  final List<String> categories;

  const _FiltersPanel({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchFilterProvider);
    final notifier = ref.read(searchFilterProvider.notifier);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CATEGORY',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((c) => _FilterChip(
                      label: c,
                      selected: state.category == c,
                      color: AppTheme.accent,
                      onTap: () => notifier.setCategory(state.category == c ? null : c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'STOCK STATUS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: StockStatus.values
                .map((s) => _FilterChip(
                      label: s.label,
                      selected: state.status == s,
                      color: s.color,
                      onTap: () => notifier.setStatus(state.status == s ? null : s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final bool hasQuery;

  const _EmptyResults({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.search_rounded,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'No matching products' : 'Search for products',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery ? 'Try different search terms or filters' : 'Type a name or apply filters',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'Sora'),
          ),
        ],
      ),
    );
  }
}
