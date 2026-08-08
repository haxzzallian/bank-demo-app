import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/retry_error_view.dart';
import '../providers/dashboard_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/stats_preview_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dashboardControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.isLoading
            ? const SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: DashboardSkeleton(),
              )
            : state.error != null && !state.hasData
            ? RetryErrorView(
                title: 'Couldn\'t load your dashboard',
                message: state.error!,
                onRetry: () =>
                    ref.read(dashboardControllerProvider.notifier).load(),
              )
            : RefreshIndicator(
                color: AppColors.cta,
                onRefresh: () =>
                    ref.read(dashboardControllerProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingHeader(phoneNumber: state.user?.phoneNumber),
                      const SizedBox(height: 24),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          BalanceCard(
                            balance: state.user?.balance,
                            phoneNumber: state.user?.phoneNumber,
                            isRefreshing: state.isRefreshing,
                            onRefresh: () => ref
                                .read(dashboardControllerProvider.notifier)
                                .refresh(),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -32,
                            child: QuickActionsRow(
                              onDeposit: () => context.push(AppRoutes.deposit),
                              onWithdraw: () =>
                                  context.push(AppRoutes.withdraw),
                              onTransfer: () =>
                                  context.push(AppRoutes.transfer),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 52),
                      StatsPreviewSection(
                        transactions: state.recentTransactions,
                      ),
                      const SizedBox(height: 28),
                      RecentTransactionsSection(
                        transactions: state.recentTransactions,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
