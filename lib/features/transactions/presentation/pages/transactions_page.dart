import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/retry_error_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../providers/transactions_list_controller.dart';
import '../widgets/transaction_list_tile.dart';

/// The full paginated transaction history — replaces the Phase 3/4
/// "coming soon" placeholder that lived here.
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(transactionsListControllerProvider.notifier).load(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(transactionsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsListControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Transactions',
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TransactionsListState state) {
    if (state.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 8,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, _) => const ShimmerBox(
          width: double.infinity,
          height: 78,
          borderRadius: 18,
        ),
      );
    }

    if (state.error != null && !state.hasData) {
      return RetryErrorView(
        title: 'Couldn\'t load your transactions',
        message: state.error!,
        onRetry: () =>
            ref.read(transactionsListControllerProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        color: AppColors.cta,
        onRefresh: () =>
            ref.read(transactionsListControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
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
                      Icons.receipt_long_outlined,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your deposits, withdrawals, and transfers will show up here.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.cta,
      onRefresh: () =>
          ref.read(transactionsListControllerProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: state.items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return _buildFooter(state);
          }
          return TransactionListTile(transaction: state.items[index]);
        },
      ),
    );
  }

  Widget _buildFooter(TransactionsListState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.cta,
            ),
          ),
        ),
      );
    }
    if (!state.hasMore && state.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('You\'re all caught up', style: AppTextStyles.caption),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
