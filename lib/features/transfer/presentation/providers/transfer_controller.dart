import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/recipient_entity.dart';
import '../../domain/entities/transfer_result_entity.dart';

class TransferState extends Equatable {
  const TransferState({
    this.isLoadingDirectory = false,
    this.directoryError,
    this.directory = const [],
    this.selectedRecipient,
    this.isSubmitting = false,
    this.submitError,
    this.result,
  });

  final bool isLoadingDirectory;
  final String? directoryError;
  final List<RecipientEntity> directory;
  final RecipientEntity? selectedRecipient;
  final bool isSubmitting;
  final String? submitError;
  final TransferResultEntity? result;

  bool get isSuccess => result != null;

  TransferState copyWith({
    bool? isLoadingDirectory,
    String? directoryError,
    List<RecipientEntity>? directory,
    RecipientEntity? selectedRecipient,
    bool clearSelectedRecipient = false,
    bool? isSubmitting,
    String? submitError,
    TransferResultEntity? result,
  }) {
    return TransferState(
      isLoadingDirectory: isLoadingDirectory ?? this.isLoadingDirectory,
      directoryError: directoryError,
      directory: directory ?? this.directory,
      selectedRecipient: clearSelectedRecipient
          ? null
          : (selectedRecipient ?? this.selectedRecipient),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingDirectory,
    directoryError,
    directory,
    selectedRecipient,
    isSubmitting,
    submitError,
    result,
  ];
}

class TransferController extends StateNotifier<TransferState> {
  TransferController(this._ref) : super(const TransferState());

  final Ref _ref;

  Future<void> loadDirectory() async {
    state = state.copyWith(isLoadingDirectory: true, directoryError: null);

    final result = await _ref.read(transferRepositoryProvider).getDirectory();
    final ownPhoneNumber = _ref.read(authControllerProvider).user?.phoneNumber;

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingDirectory: false,
        directoryError: failure.message,
      ),
      (recipients) => state = state.copyWith(
        isLoadingDirectory: false,
        directory: recipients
            .where((r) => r.phoneNumber != ownPhoneNumber)
            .toList(),
      ),
    );
  }

  void selectRecipient(RecipientEntity recipient) {
    state = state.copyWith(selectedRecipient: recipient);
  }

  void clearRecipient() {
    state = state.copyWith(clearSelectedRecipient: true);
  }

  Future<void> submit(double amount) async {
    final recipient = state.selectedRecipient;
    if (recipient == null) return;

    state = state.copyWith(isSubmitting: true, submitError: null);

    final result = await _ref
        .read(transferRepositoryProvider)
        .transfer(phoneNumber: recipient.phoneNumber, amount: amount);

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        submitError: failure.message,
      ),
      (result) => state = state.copyWith(
        isSubmitting: false,
        result: result,
        submitError: null,
      ),
    );
  }
}

final transferControllerProvider =
    StateNotifierProvider.autoDispose<TransferController, TransferState>(
      (ref) => TransferController(ref),
    );
