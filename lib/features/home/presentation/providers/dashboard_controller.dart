import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

const int _recentTransactionsLimit = 5;

class DashboardState extends Equatable {
  const DashboardState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.user,
    this.recentTransactions = const [],
    this.error,
  });

  final bool isLoading;
  final bool isRefreshing;
  final UserEntity? user;
  final List<TransactionEntity> recentTransactions;
  final String? error;

  bool get hasData => user != null;

  DashboardState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    UserEntity? user,
    List<TransactionEntity>? recentTransactions,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      user: user ?? this.user,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    user,
    recentTransactions,
    error,
  ];
}

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._ref) : super(const DashboardState());

  final Ref _ref;

  Future<void> load() => _fetch(isRefresh: false);

  Future<void> refresh() => _fetch(isRefresh: true);

  Future<void> _fetch({required bool isRefresh}) async {
    state = state.copyWith(
      isLoading: !isRefresh && !state.hasData,
      isRefreshing: isRefresh,
      error: null,
    );

    final authRepository = _ref.read(authRepositoryProvider);
    final transactionsRepository = _ref.read(transactionsRepositoryProvider);

    final results = await Future.wait([
      authRepository.getCurrentUser(),
      transactionsRepository.getTransactions(limit: _recentTransactionsLimit),
    ]);

    final userResult = results[0];
    final transactionsResult = results[1];

    final failure =
        userResult.fold((f) => f, (_) => null) ??
        transactionsResult.fold((f) => f, (_) => null);

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: failure.message,
      );
      return;
    }

    final user = userResult.fold((_) => null, (u) => u as UserEntity);
    final page = transactionsResult.fold(
      (_) => null,
      (p) => p as TransactionsPage,
    );

    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      user: user,
      recentTransactions: page?.items ?? const [],
      error: null,
    );
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>(
      (ref) => DashboardController(ref),
    );
