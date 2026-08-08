import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/withdraw_result_entity.dart';

class WithdrawState extends Equatable {
  const WithdrawState({this.isSubmitting = false, this.error, this.result});

  final bool isSubmitting;
  final String? error;
  final WithdrawResultEntity? result;

  bool get isSuccess => result != null;

  WithdrawState copyWith({
    bool? isSubmitting,
    String? error,
    WithdrawResultEntity? result,
  }) {
    return WithdrawState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error, result];
}

class WithdrawController extends StateNotifier<WithdrawState> {
  WithdrawController(this._ref) : super(const WithdrawState());

  final Ref _ref;

  Future<void> submit(double amount) async {
    state = state.copyWith(isSubmitting: true, error: null);

    final result = await _ref
        .read(withdrawRepositoryProvider)
        .withdraw(amount: amount);

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
}

final withdrawControllerProvider =
    StateNotifierProvider.autoDispose<WithdrawController, WithdrawState>(
      (ref) => WithdrawController(ref),
    );
