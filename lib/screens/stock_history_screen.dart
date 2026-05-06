// lib/screens/stock_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/stock_log.dart';
import '../providers/inventory_providers.dart';
import '../utils/app_theme.dart';

class StockHistoryScreen extends ConsumerStatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  ConsumerState<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends ConsumerState<StockHistoryScreen> {
  StockLogType? _filterType;

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(logsProvider);
    final logs = _filterType == null
        ? allLogs
        : allLogs.where((l) => l.type == _filterType).toList();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text('Stock History'),
      ),
      body: Column(
        children: [
          // Summary cards
          _SummaryBar(logs: allLogs),

          // Filter chips
          _FilterBar(
            selected: _filterType,
            onChanged: (t) => setState(() => _filterType = t),
          ),

          // List
          Expanded(
            child: logs.isEmpty
                ? _EmptyHistory(hasFilter: _filterType != null)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: logs.length,
                    itemBuilder: (ctx, i) {
                      final log = logs[i];
                      final prevLog = i + 1 < logs.length ? logs[i + 1] : null;
                      final showDateHeader = prevLog == null ||
                          !_isSameDay(log.timestamp, prevLog.timestamp);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i == 0 || !_isSameDay(log.timestamp, logs[i - 1].timestamp))
                            _DateHeader(date: log.timestamp),
                          _LogItem(log: log),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _SummaryBar extends StatelessWidget {
  final List<StockLog> logs;

  const _SummaryBar({required this.logs});

  @override
  Widget build(BuildContext context) {
    final totalIn = logs
        .where((l) => l.type == StockLogType.stockIn)
        .fold(0.0, (sum, l) => sum + l.quantity);
    final totalOut = logs
        .where((l) => l.type == StockLogType.stockOut)
        .fold(0.0, (sum, l) => sum + l.quantity);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SumItem(
              label: 'Total Received',
              value: totalIn.toStringAsFixed(0),
              color: AppTheme.stockNormal,
              icon: Icons.trending_up_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: _SumItem(
              label: 'Total Consumed',
              value: totalOut.toStringAsFixed(0),
              color: AppTheme.accentOrange,
              icon: Icons.trending_down_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: _SumItem(
              label: 'Transactions',
              value: '${logs.length}',
              color: AppTheme.accent,
              icon: Icons.receipt_long_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _SumItem({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Sora',
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontFamily: 'Sora',
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final StockLogType? selected;
  final void Function(StockLogType?) onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            color: AppTheme.accent,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Stock In',
            selected: selected == StockLogType.stockIn,
            color: AppTheme.stockNormal,
            icon: Icons.add_rounded,
            onTap: () => onChanged(
              selected == StockLogType.stockIn ? null : StockLogType.stockIn,
            ),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Stock Out',
            selected: selected == StockLogType.stockOut,
            color: AppTheme.accentOrange,
            icon: Icons.remove_rounded,
            onTap: () => onChanged(
              selected == StockLogType.stockOut ? null : StockLogType.stockOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: selected ? color : AppTheme.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Sora',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = 'Today';
    } else if (d == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('EEEE, MMMM d').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: Colors.white.withOpacity(0.07), height: 1),
          ),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final StockLog log;

  const _LogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final isIn = log.type == StockLogType.stockIn;
    final color = isIn ? AppTheme.stockNormal : AppTheme.accentOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIn ? Icons.add_rounded : Icons.remove_rounded,
              color: color,
              size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      DateFormat('h:mm a').format(log.timestamp),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontFamily: 'Sora',
                      ),
                    ),
                    if (log.note != null && log.note!.isNotEmpty) ...[
                      const Text(' · ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      Expanded(
                        child: Text(
                          log.note!,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontFamily: 'Sora'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIn ? '+' : '-'}${log.quantity.toStringAsFixed(log.quantity % 1 == 0 ? 0 : 1)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Sora',
                ),
              ),
              Text(
                '${log.quantityBefore.toStringAsFixed(0)} → ${log.quantityAfter.toStringAsFixed(0)}',
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

class _EmptyHistory extends StatelessWidget {
  final bool hasFilter;

  const _EmptyHistory({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No logs for this filter' : 'No stock movements yet',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter ? 'Try a different filter' : 'Start updating stock to see history',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontFamily: 'Sora'),
          ),
        ],
      ),
    );
  }
}
