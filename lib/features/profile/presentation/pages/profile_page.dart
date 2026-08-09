import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/retry_error_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../home/presentation/providers/dashboard_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(dashboardControllerProvider);
      if (!state.hasData) {
        ref.read(dashboardControllerProvider.notifier).load();
      }
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Log out?',
      message: 'You\'ll need your phone number and password to sign back in.',
      confirmLabel: 'Log Out',
      destructive: true,
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Profile',
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state.isLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ShimmerGroup(
          child: Column(
            children: [
              const ShimmerBox(width: 88, height: 88, borderRadius: 44),
              const SizedBox(height: 24),
              const ShimmerBox(
                width: double.infinity,
                height: 180,
                borderRadius: 20,
              ),
            ],
          ),
        ),
      );
    }

    if (state.error != null && !state.hasData) {
      return RetryErrorView(
        title: 'Couldn\'t load your profile',
        message: state.error!,
        onRetry: () => ref.read(dashboardControllerProvider.notifier).load(),
      );
    }

    final user = state.user;

    return RefreshIndicator(
      color: AppColors.cta,
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cta, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.phoneNumber ?? '—',
                  style: AppTextStyles.title.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  user == null
                      ? '—'
                      : 'Member since ${DateFormatter.date(user.created)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.call_outlined,
                  label: 'Phone Number',
                  value: user?.phoneNumber ?? '—',
                ),
                const Divider(height: 1, color: AppColors.background),
                _InfoRow(
                  icon: Icons.account_balance_rounded,
                  label: 'Account Number',
                  value: user?.phoneNumber ?? '—',
                  caption:
                      'Same as your phone number — no separate account number.',
                ),
                const Divider(height: 1, color: AppColors.background),
                _InfoRow(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Current Balance',
                  value: user == null
                      ? '—'
                      : CurrencyFormatter.format(user.balance),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Log Out',
            destructive: true,
            onPressed: _confirmLogout,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    caption!,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
