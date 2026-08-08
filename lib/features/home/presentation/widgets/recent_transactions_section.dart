import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key, required this.transactions});

  final List<TransactionEntity> transactions;

  void _viewAll(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Full transaction history is coming soon'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),
            TextButton(
              onPressed: () => _viewAll(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.cta),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (transactions.isEmpty)
          const _EmptyTransactions()
        else
          Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                _TransactionTile(transaction: transactions[i]),
                if (i != transactions.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.success : AppColors.error;
    final title = transaction.counterparty?.isNotEmpty == true
        ? transaction.counterparty!
        : (transaction.note?.isNotEmpty == true
              ? transaction.note!
              : (isCredit ? 'Deposit' : 'Withdrawal'));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.relative(transaction.created),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '−'} ${CurrencyFormatter.format(transaction.amount)}',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Your deposits, withdrawals, and transfers will show up here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
