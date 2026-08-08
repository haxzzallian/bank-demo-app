import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/deposit_result_entity.dart';

class DepositState extends Equatable {
  const DepositState({this.isSubmitting = false, this.error, this.result});

  final bool isSubmitting;
  final String? error;
  final DepositResultEntity? result;

  bool get isSuccess => result != null;

  DepositState copyWith({
    bool? isSubmitting,
    String? error,
    DepositResultEntity? result,
  }) {
    return DepositState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error, result];
}

class DepositController extends StateNotifier<DepositState> {
  DepositController(this._ref) : super(const DepositState());

  final Ref _ref;

  Future<void> submit(double amount) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _ref
        .read(depositRepositoryProvider)
        .deposit(amount: amount);

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, error: failure.message),
      (result) => state = state.copyWith(
        isSubmitting: false,
        result: result,
        error: null,
      ),
    );
  }

  /// Resets to a fresh form — used when the user deposits again from the
  /// success view.
  void reset() => state = const DepositState();
}

final depositControllerProvider =
    StateNotifierProvider.autoDispose<DepositController, DepositState>(
      (ref) => DepositController(ref),
    );
