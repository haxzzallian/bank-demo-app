import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/analytics_controller.dart';

class GroupedBarChart extends StatelessWidget {
  const GroupedBarChart({
    super.key,
    required this.buckets,
    this.chartHeight = 140,
  });

  final List<AnalyticsBucket> buckets;
  final double chartHeight;

  @override
  Widget build(BuildContext context) {
    final maxValue = buckets
        .expand((b) => [b.credit, b.debit])
        .fold<double>(0, (max, v) => v > max ? v : max);
    final scale = maxValue == 0 ? 0.0 : chartHeight / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Legend(),
        const SizedBox(height: 16),
        SizedBox(
          height: chartHeight + 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bucket in buckets)
                Expanded(
                  child: _BarGroup(
                    bucket: bucket,
                    scale: scale,
                    maxHeight: chartHeight,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendSwatch(color: AppColors.success, label: 'Deposits'),
        SizedBox(width: 16),
        _LegendSwatch(color: AppColors.error, label: 'Withdrawals'),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BarGroup extends StatelessWidget {
  const _BarGroup({
    required this.bucket,
    required this.scale,
    required this.maxHeight,
  });

  final AnalyticsBucket bucket;
  final double scale;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${bucket.label}\nDeposits: ${CurrencyFormatter.format(bucket.credit)}\nWithdrawals: ${CurrencyFormatter.format(bucket.debit)}',
      textAlign: TextAlign.center,
      triggerMode: TooltipTriggerMode.tap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: maxHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Bar(
                  value: bucket.credit,
                  scale: scale,
                  color: AppColors.success,
                ),
                const SizedBox(width: 3),
                _Bar(value: bucket.debit, scale: scale, color: AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bucket.label,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.scale, required this.color});

  final double value;
  final double scale;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final targetHeight = (value * scale).clamp(0.0, double.infinity);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetHeight),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, height, _) => Container(
        width: 10,
        height: height < 2 && value > 0 ? 2 : height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ),
    );
  }
}
