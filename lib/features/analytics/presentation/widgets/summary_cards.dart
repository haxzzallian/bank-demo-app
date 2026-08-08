import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/analytics_controller.dart';

/// Four headline stat tiles — per the dataviz skill, values stay in ink;
/// only the icon badge carries color/direction, never the text itself.
class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.state});

  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final isNetPositive = state.netChange >= 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _StatCard(
          label: 'Total In',
          value: CurrencyFormatter.formatWhole(state.totalIn),
          icon: Icons.south_west_rounded,
          color: AppColors.success,
        ),
        _StatCard(
          label: 'Total Out',
          value: CurrencyFormatter.formatWhole(state.totalOut),
          icon: Icons.north_east_rounded,
          color: AppColors.error,
        ),
        _StatCard(
          label: 'Net Change',
          value: CurrencyFormatter.formatWhole(state.netChange),
          icon: isNetPositive
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          color: isNetPositive ? AppColors.success : AppColors.error,
        ),
        _StatCard(
          label: 'Transactions',
          value: '${state.transactionCount}',
          icon: Icons.receipt_long_rounded,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontSize: 17),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
