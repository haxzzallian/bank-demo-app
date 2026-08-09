import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class AnalyticsBucket extends Equatable {
  const AnalyticsBucket({
    required this.label,
    required this.credit,
    required this.debit,
  });

  final String label;
  final double credit;
  final double debit;

  @override
  List<Object?> get props => [label, credit, debit];
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.totalIn = 0,
    this.totalOut = 0,
    this.transactionCount = 0,
    this.weeklyBuckets = const [],
    this.monthlyBuckets = const [],
  });

  final bool isLoading;
  final String? error;
  final double totalIn;
  final double totalOut;
  final int transactionCount;
  final List<AnalyticsBucket> weeklyBuckets;
  final List<AnalyticsBucket> monthlyBuckets;

  double get netChange => totalIn - totalOut;
  bool get hasData => transactionCount > 0;

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    double? totalIn,
    double? totalOut,
    int? transactionCount,
    List<AnalyticsBucket>? weeklyBuckets,
    List<AnalyticsBucket>? monthlyBuckets,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalIn: totalIn ?? this.totalIn,
      totalOut: totalOut ?? this.totalOut,
      transactionCount: transactionCount ?? this.transactionCount,
      weeklyBuckets: weeklyBuckets ?? this.weeklyBuckets,
      monthlyBuckets: monthlyBuckets ?? this.monthlyBuckets,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    totalIn,
    totalOut,
    transactionCount,
    weeklyBuckets,
    monthlyBuckets,
  ];
}

const List<String> _weekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];
const List<String> _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class AnalyticsController extends StateNotifier<AnalyticsState> {
  AnalyticsController(this._ref) : super(const AnalyticsState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _ref
        .read(transactionsRepositoryProvider)
        .getTransactions(limit: 200, offset: 0);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (page) {
        final transactions = page.items;
        state = state.copyWith(
          isLoading: false,
          error: null,
          totalIn: _sum(transactions, isCredit: true),
          totalOut: _sum(transactions, isCredit: false),
          transactionCount: transactions.length,
          weeklyBuckets: _weeklyBuckets(transactions),
          monthlyBuckets: _monthlyBuckets(transactions),
        );
      },
    );
  }

  double _sum(List<TransactionEntity> transactions, {required bool isCredit}) {
    return transactions
        .where((t) => t.isCredit == isCredit)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  List<AnalyticsBucket> _weeklyBuckets(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final inRange = transactions.where((t) {
        final local = t.created.toLocal();
        return local.year == day.year &&
            local.month == day.month &&
            local.day == day.day;
      });
      return AnalyticsBucket(
        label: _weekdayLabels[day.weekday - 1],
        credit: _sum(inRange.toList(), isCredit: true),
        debit: _sum(inRange.toList(), isCredit: false),
      );
    });
  }

  List<AnalyticsBucket> _monthlyBuckets(List<TransactionEntity> transactions) {
    final now = DateTime.now();

    return List.generate(6, (i) {
      final offset = 5 - i;
      final monthDate = DateTime(now.year, now.month - offset, 1);
      final inRange = transactions.where((t) {
        final local = t.created.toLocal();
        return local.year == monthDate.year && local.month == monthDate.month;
      });
      return AnalyticsBucket(
        label: _monthLabels[monthDate.month - 1],
        credit: _sum(inRange.toList(), isCredit: true),
        debit: _sum(inRange.toList(), isCredit: false),
      );
    });
  }
}

final analyticsControllerProvider =
    StateNotifierProvider.autoDispose<AnalyticsController, AnalyticsState>(
      (ref) => AnalyticsController(ref),
    );
