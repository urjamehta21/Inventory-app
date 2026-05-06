// lib/screens/product_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';
import 'stock_update_screen.dart';

class ProductManagementScreen extends ConsumerWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              ),
              icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.accent),
              label: const Text(
                'Add',
                style: TextStyle(color: AppTheme.accent, fontFamily: 'Sora', fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: products.isEmpty
          ? _EmptyState(
              onAdd: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: products.length,
              itemBuilder: (ctx, i) {
                final product = products[i];
                return ProductCard(
                  product: product,
                  onTap: () => _showProductDetail(context, ref, product),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(product: product),
                    ),
                  ),
                  onDelete: () => _confirmDelete(context, ref, product),
                  onStockUpdate: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockUpdateScreen(product: product),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.primary,
      ),
    );
  }

  void _showProductDetail(BuildContext context, WidgetRef ref, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Delete Product', style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Sora')),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Sora'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'Sora')),
          ),
          TextButton(
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} deleted'),
                  backgroundColor: AppTheme.cardBg,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger, fontFamily: 'Sora')),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: AppTheme.textSecondary, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Products Yet',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to start\ntracking inventory',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontFamily: 'Sora'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final Product product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = product.stockStatus;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontFamily: 'Sora'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: status.color.withOpacity(0.3)),
                ),
                child: Text(
                  '${product.quantity} ${product.unit}',
                  style: TextStyle(
                    color: status.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow('Category', product.category),
          _DetailRow('Unit', product.unit),
          _DetailRow('Minimum Threshold', '${product.minimumThreshold} ${product.unit}'),
          if (product.description != null) _DetailRow('Notes', product.description!),
          if (product.costPrice != null) _DetailRow('Cost Price', '₹${product.costPrice!.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'Sora'),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
