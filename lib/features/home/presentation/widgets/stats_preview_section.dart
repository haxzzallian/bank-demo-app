import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// A compact money-in vs money-out preview, computed from whatever recent
/// transactions the dashboard already fetched. The full breakdown lives in
/// Phase 8's Analytics screen — this is deliberately just a taste, and says
/// so in its caption rather than implying it's a monthly total.
class StatsPreviewSection extends StatelessWidget {
  const StatsPreviewSection({super.key, required this.transactions});

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final moneyIn = transactions
        .where((t) => t.isCredit)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final moneyOut = transactions
        .where((t) => !t.isCredit)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final total = moneyIn + moneyOut;
    final inShare = total == 0 ? 0.0 : moneyIn / total;
    final outShare = total == 0 ? 0.0 : moneyOut / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Snapshot',
          style: AppTextStyles.title.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          'From your last ${transactions.length} transaction${transactions.length == 1 ? '' : 's'}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatMeterTile(
                label: 'Money In',
                icon: Icons.south_west_rounded,
                color: AppColors.success,
                amount: moneyIn,
                share: inShare,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatMeterTile(
                label: 'Money Out',
                icon: Icons.north_east_rounded,
                color: AppColors.error,
                amount: moneyOut,
                share: outShare,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatMeterTile extends StatelessWidget {
  const _StatMeterTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
    required this.share,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatWhole(amount),
            style: AppTextStyles.title.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 10),
          // Meter: fill carries magnitude, track is a lighter step of the
          // same hue so the proportion reads even before the label is read.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: share.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value == 0 ? 0.02 : value,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
