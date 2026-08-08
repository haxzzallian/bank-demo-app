import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/amount_entry.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/balance_summary_card.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/success_check.dart';
import '../../../home/presentation/providers/dashboard_controller.dart';
import '../providers/withdraw_controller.dart';

class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  final _amountController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_amountController.text);

  void _selectPreset(double amount) {
    FocusScope.of(context).unfocus();
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
      _validationError = null;
    });
  }

  Future<void> _submit(double? availableBalance) async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      setState(() => _validationError = 'Enter an amount greater than zero.');
      return;
    }
    if (availableBalance != null && amount > availableBalance) {
      setState(
        () => _validationError = 'That\'s more than your available balance.',
      );
      return;
    }
    setState(() => _validationError = null);

    final confirmed = await showConfirmSheet(
      context,
      title: 'Confirm Withdrawal',
      rows: [ConfirmRow('Amount', CurrencyFormatter.format(amount))],
      confirmLabel: 'Withdraw',
    );
    if (confirmed != true) return;
    if (!mounted) return;

    await ref.read(withdrawControllerProvider.notifier).submit(amount);
  }

  void _done() {
    ref.read(dashboardControllerProvider.notifier).refresh();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawControllerProvider);
    final availableBalance = ref
        .watch(dashboardControllerProvider)
        .user
        ?.balance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.isSuccess
            ? _WithdrawSuccessView(state: state, onDone: _done)
            : _WithdrawFormView(
                amountController: _amountController,
                validationError: _validationError,
                submitError: state.error,
                isSubmitting: state.isSubmitting,
                availableBalance: availableBalance,
                onPresetSelected: _selectPreset,
                onSubmit: () => _submit(availableBalance),
              ),
      ),
    );
  }
}

class _WithdrawFormView extends StatelessWidget {
  const _WithdrawFormView({
    required this.amountController,
    required this.validationError,
    required this.submitError,
    required this.isSubmitting,
    required this.availableBalance,
    required this.onPresetSelected,
    required this.onSubmit,
  });

  final TextEditingController amountController;
  final String? validationError;
  final String? submitError;
  final bool isSubmitting;
  final double? availableBalance;
  final ValueChanged<double> onPresetSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final errorMessage = validationError ?? submitError;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textPrimary,
                tooltip: 'Back',
              ),
              Text(
                'Withdraw',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'How much would you like to withdraw?',
            style: AppTextStyles.subtitle,
          ),
          if (availableBalance != null) ...[
            const SizedBox(height: 4),
            Text(
              'Available: ${CurrencyFormatter.format(availableBalance!)}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 28),
          AmountEntry(
            controller: amountController,
            onPresetSelected: onPresetSelected,
          ),
          const SizedBox(height: 8),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: AppErrorBanner(message: errorMessage),
            ),
          const SizedBox(height: 40),
          AppButton(
            label: 'Withdraw',
            onPressed: onSubmit,
            isLoading: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _WithdrawSuccessView extends StatelessWidget {
  const _WithdrawSuccessView({required this.state, required this.onDone});

  final WithdrawState state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SuccessCheck(),
          const SizedBox(height: 24),
          Text(
            'Withdrawal Successful',
            style: AppTextStyles.title.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You withdrew ${CurrencyFormatter.format(result.withdrawal)}',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          BalanceSummaryCard(
            label: 'New Balance',
            value: CurrencyFormatter.format(result.balance),
          ),
          const SizedBox(height: 40),
          AppButton(label: 'Done', onPressed: onDone),
        ],
      ),
    );
  }
}
