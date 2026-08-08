import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/transaction_entity.dart';

const int _pageSize = 20;

class TransactionsListState extends Equatable {
  const TransactionsListState({
    this.items = const [],
    this.offset = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.error,
  });

  final List<TransactionEntity> items;
  final int offset;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? error;

  bool get hasData => items.isNotEmpty;

  TransactionsListState copyWith({
    List<TransactionEntity>? items,
    int? offset,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? error,
  }) {
    return TransactionsListState(
      items: items ?? this.items,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    items,
    offset,
    hasMore,
    isLoading,
    isLoadingMore,
    isRefreshing,
    error,
  ];
}

class TransactionsListController extends StateNotifier<TransactionsListState> {
  TransactionsListController(this._ref) : super(const TransactionsListState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _ref
        .read(transactionsRepositoryProvider)
        .getTransactions(limit: _pageSize, offset: 0);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (page) => state = state.copyWith(
        isLoading: false,
        items: page.items,
        offset: page.items.length,
        hasMore: page.hasMore,
        error: null,
      ),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);

    final result = await _ref
        .read(transactionsRepositoryProvider)
        .getTransactions(limit: _pageSize, offset: 0);

    result.fold(
      (failure) =>
          state = state.copyWith(isRefreshing: false, error: failure.message),
      (page) => state = state.copyWith(
        isRefreshing: false,
        items: page.items,
        offset: page.items.length,
        hasMore: page.hasMore,
        error: null,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _ref
        .read(transactionsRepositoryProvider)
        .getTransactions(limit: _pageSize, offset: state.offset);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingMore: false, error: failure.message),
      (page) => state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        offset: state.offset + page.items.length,
        hasMore: page.hasMore,
      ),
    );
  }
}

final transactionsListControllerProvider =
    StateNotifierProvider.autoDispose<
      TransactionsListController,
      TransactionsListState
    >((ref) => TransactionsListController(ref));
