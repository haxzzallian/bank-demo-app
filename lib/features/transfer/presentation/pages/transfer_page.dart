import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/amount_entry.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/retry_error_view.dart';
import '../../../../core/widgets/success_check.dart';
import '../../../home/presentation/providers/dashboard_controller.dart';
import '../../domain/entities/recipient_entity.dart';
import '../providers/transfer_controller.dart';

class TransferPage extends ConsumerStatefulWidget {
  const TransferPage({super.key});

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  String _searchQuery = '';
  String? _validationError;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(transferControllerProvider.notifier).loadDirectory(),
    );
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _submit(
    RecipientEntity recipient,
    double? availableBalance,
  ) async {
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
      title: 'Confirm Transfer',
      rows: [
        ConfirmRow('Recipient', recipient.phoneNumber),
        ConfirmRow('Amount', CurrencyFormatter.format(amount)),
      ],
      confirmLabel: 'Send',
    );
    if (confirmed != true) return;
    if (!mounted) return;

    await ref.read(transferControllerProvider.notifier).submit(amount);
  }

  void _done() {
    ref.read(dashboardControllerProvider.notifier).refresh();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferControllerProvider);
    final availableBalance = ref
        .watch(dashboardControllerProvider)
        .user
        ?.balance;

    Widget body;
    if (state.isSuccess) {
      body = _TransferSuccessView(state: state, onDone: _done);
    } else if (state.selectedRecipient == null) {
      final filtered = _searchQuery.isEmpty
          ? state.directory
          : state.directory
                .where(
                  (r) => r.phoneNumber.toLowerCase().contains(_searchQuery),
                )
                .toList();
      body = _RecipientSelectionView(
        searchController: _searchController,
        isLoading: state.isLoadingDirectory,
        error: state.directoryError,
        recipients: filtered,
        hasQuery: _searchQuery.isNotEmpty,
        onRetry: () =>
            ref.read(transferControllerProvider.notifier).loadDirectory(),
        onSelect: (r) =>
            ref.read(transferControllerProvider.notifier).selectRecipient(r),
      );
    } else {
      body = _AmountView(
        recipient: state.selectedRecipient!,
        amountController: _amountController,
        validationError: _validationError,
        submitError: state.submitError,
        isSubmitting: state.isSubmitting,
        availableBalance: availableBalance,
        onBack: () =>
            ref.read(transferControllerProvider.notifier).clearRecipient(),
        onPresetSelected: _selectPreset,
        onSubmit: () => _submit(state.selectedRecipient!, availableBalance),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: body),
    );
  }
}

class _RecipientSelectionView extends StatelessWidget {
  const _RecipientSelectionView({
    required this.searchController,
    required this.isLoading,
    required this.error,
    required this.recipients,
    required this.hasQuery,
    required this.onRetry,
    required this.onSelect,
  });

  final TextEditingController searchController;
  final bool isLoading;
  final String? error;
  final List<RecipientEntity> recipients;
  final bool hasQuery;
  final VoidCallback onRetry;
  final ValueChanged<RecipientEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textPrimary,
              ),
              Text(
                'Transfer',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
          child: Text('Who are you sending to?', style: AppTextStyles.subtitle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by phone number',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.cta, width: 1.6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, _) => Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    if (error != null) {
      return RetryErrorView(message: error!, onRetry: onRetry);
    }

    if (recipients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline_rounded,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                hasQuery
                    ? 'No matching accounts found.'
                    : 'No other accounts yet.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: recipients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final recipient = recipients[index];
        return _RecipientTile(
          recipient: recipient,
          onTap: () => onSelect(recipient),
        );
      },
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({required this.recipient, required this.onTap});

  final RecipientEntity recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.cta, AppColors.secondary],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recipient.phoneNumber,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountView extends StatelessWidget {
  const _AmountView({
    required this.recipient,
    required this.amountController,
    required this.validationError,
    required this.submitError,
    required this.isSubmitting,
    required this.availableBalance,
    required this.onBack,
    required this.onPresetSelected,
    required this.onSubmit,
  });

  final RecipientEntity recipient;
  final TextEditingController amountController;
  final String? validationError;
  final String? submitError;
  final bool isSubmitting;
  final double? availableBalance;
  final VoidCallback onBack;
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
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.textPrimary,
              ),
              Text(
                'Transfer',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sending to ${recipient.phoneNumber}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (availableBalance != null) ...[
            const SizedBox(height: 12),
            Text(
              'Available: ${CurrencyFormatter.format(availableBalance!)}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 24),
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
            label: 'Send',
            onPressed: onSubmit,
            isLoading: isSubmitting,
          ),
        ],
      ),
    );
  }
}

class _TransferSuccessView extends StatelessWidget {
  const _TransferSuccessView({required this.state, required this.onDone});

  final TransferState state;
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
            'Transfer Successful',
            style: AppTextStyles.title.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You sent ${CurrencyFormatter.format(result.sent)} to ${result.to}',
            style: AppTextStyles.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New Balance', style: AppTextStyles.caption),
                Text(
                  CurrencyFormatter.format(result.balance),
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          AppButton(label: 'Done', onPressed: onDone),
        ],
      ),
    );
  }
}
