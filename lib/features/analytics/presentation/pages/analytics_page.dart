import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/retry_error_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../providers/analytics_controller.dart';
import '../widgets/grouped_bar_chart.dart';
import '../widgets/summary_cards.dart';

/// Full Analytics screen — replaces the Phase 3/4 "coming soon" placeholder.
///
/// No dedicated analytics endpoint exists in the API, so every number here
/// is computed client-side from `GET /transactions`. The API only models
/// `credit`/`debit` (no separate deposit/transfer-in distinction), so
/// "Deposits" = credit and "Withdrawals" = debit throughout, matching the
/// same mapping the dashboard's Activity Snapshot already uses.
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Analytics',
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AnalyticsState state) {
    if (state.isLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 90, borderRadius: 18)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 90, borderRadius: 18)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 90, borderRadius: 18)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 90, borderRadius: 18)),
              ],
            ),
            const SizedBox(height: 24),
            const ShimmerBox(
              width: double.infinity,
              height: 220,
              borderRadius: 20,
            ),
          ],
        ),
      );
    }

    if (state.error != null && !state.hasData) {
      return RetryErrorView(
        title: 'Couldn\'t load your analytics',
        message: state.error!,
        onRetry: () => ref.read(analyticsControllerProvider.notifier).load(),
      );
    }

    if (!state.hasData) {
      return RefreshIndicator(
        color: AppColors.cta,
        onRefresh: () => ref.read(analyticsControllerProvider.notifier).load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights_outlined,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing to analyze yet',
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Once you deposit, withdraw, or transfer, your activity shows up here.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.cta,
      onRefresh: () => ref.read(analyticsControllerProvider.notifier).load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCards(state: state),
            const SizedBox(height: 28),
            Text(
              'Monthly Summary',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Deposits vs withdrawals, last 6 months',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            _ChartCard(child: GroupedBarChart(buckets: state.monthlyBuckets)),
            const SizedBox(height: 28),
            Text(
              'Weekly Summary',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Deposits vs withdrawals, last 7 days',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            _ChartCard(child: GroupedBarChart(buckets: state.weeklyBuckets)),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
