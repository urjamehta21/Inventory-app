// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/stock_log.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final products = ref.watch(productsProvider);
    final lowCount = ref.watch(lowStockCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: RefreshIndicator(
        color: AppTheme.accent,
        onRefresh: () async {
          ref.invalidate(productsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const Text(
                      'Inventory Overview',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (lowCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            '$lowCount alerts',
                            style: const TextStyle(
                              color: AppTheme.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats grid
                  _StatsGrid(
                    total: stats['totalProducts'] as int,
                    low: stats['lowStockCount'] as int,
                    out: stats['outOfStockCount'] as int,
                    normal: (stats['totalProducts'] as int) -
                        (stats['lowStockCount'] as int) -
                        (stats['outOfStockCount'] as int),
                  ),
                  const SizedBox(height: 24),

                  // Low stock alerts
                  if ((stats['lowStockItems'] as List).isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Stock Alerts',
                      icon: Icons.notifications_active_rounded,
                      color: AppTheme.danger,
                      count: (stats['lowStockItems'] as List).length,
                    ),
                    const SizedBox(height: 12),
                    ...(stats['lowStockItems'] as List<Product>).map((p) =>
                      _AlertItem(product: p)),
                    const SizedBox(height: 24),
                  ],

                  // Recent Activity
                  if ((stats['recentLogs'] as List).isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Recent Activity',
                      icon: Icons.history_rounded,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(height: 12),
                    ...(stats['recentLogs'] as List<StockLog>).take(6).map((l) =>
                      _ActivityItem(log: l)),
                    const SizedBox(height: 24),
                  ],

                  // Stock distribution
                  if (products.isNotEmpty) ...[
                    const _SectionHeader(
                      title: 'Stock Distribution',
                      icon: Icons.donut_large_rounded,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(height: 12),
                    _StockDistributionCard(products: products),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int total, low, out, normal;

  const _StatsGrid({required this.total, required this.low, required this.out, required this.normal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Total Products',
              value: '$total',
              icon: Icons.inventory_2_rounded,
              color: AppTheme.accent,
              isLarge: true,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'In Stock',
              value: '$normal',
              icon: Icons.check_circle_rounded,
              color: AppTheme.stockNormal,
              isLarge: true,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(
              label: 'Low Stock',
              value: '$low',
              icon: Icons.warning_amber_rounded,
              color: AppTheme.stockWarning,
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(
              label: 'Out of Stock',
              value: '$out',
              icon: Icons.remove_circle_rounded,
              color: AppTheme.stockOut,
            )),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: isLarge ? 20 : 18),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: isLarge ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'Sora',
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final Product product;

  const _AlertItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final status = product.stockStatus;
    final color = status.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Sora',
                  ),
                ),
                Text(
                  'Current: ${product.quantity} ${product.unit} · Min: ${product.minimumThreshold} ${product.unit}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Sora',
                  ),
                ),
              ],
            ),
          ),
          StockStatusBadge(status: status, compact: true),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final StockLog log;

  const _ActivityItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final isIn = log.type == StockLogType.stockIn;
    final color = isIn ? AppTheme.stockNormal : AppTheme.accentOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.productName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(log.timestamp),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Sora',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIn ? '+' : '-'}${log.quantity.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                ),
              ),
              Text(
                '→ ${log.quantityAfter.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontFamily: 'Sora',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sora',
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StockDistributionCard extends StatelessWidget {
  final List<Product> products;

  const _StockDistributionCard({required this.products});

  @override
  Widget build(BuildContext context) {
    final statusCounts = <StockStatus, int>{};
    for (final p in products) {
      statusCounts[p.stockStatus] = (statusCounts[p.stockStatus] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          ...StockStatus.values.map((s) {
            final count = statusCounts[s] ?? 0;
            final pct = products.isEmpty ? 0.0 : count / products.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: s.color),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: Text(
                      s.label,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(s.color.withOpacity(0.7)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: s.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
