// lib/widgets/stock_status_badge.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class StockStatusBadge extends StatelessWidget {
  final StockStatus status;
  final bool compact;

  const StockStatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora',
            ),
          ),
        ],
      ),
    );
  }
}

class StockProgressBar extends StatelessWidget {
  final double quantity;
  final double threshold;
  final double? maxQuantity;

  const StockProgressBar({
    super.key,
    required this.quantity,
    required this.threshold,
    this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final max = maxQuantity ?? (threshold * 3).clamp(threshold * 2, double.infinity);
    final progress = (quantity / max).clamp(0.0, 1.0);
    final thresholdPos = (threshold / max).clamp(0.0, 1.0);

    Color barColor;
    if (quantity <= 0) {
      barColor = AppTheme.stockOut;
    } else if (quantity <= threshold) {
      barColor = AppTheme.stockLow;
    } else if (quantity <= threshold * 1.5) {
      barColor = AppTheme.stockWarning;
    } else {
      barColor = AppTheme.stockNormal;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
        // Threshold marker
        Positioned(
          left: MediaQuery.of(context).size.width * thresholdPos * 0.7,
          child: Container(
            width: 2,
            height: 6,
            color: AppTheme.warning.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
