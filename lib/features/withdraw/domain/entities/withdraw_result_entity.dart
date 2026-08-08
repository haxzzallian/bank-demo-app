import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

/// Mirrors `WithdrawSuccess.data`: `{ withdrawal, balance, transaction }`.
class WithdrawResultEntity extends Equatable {
  const WithdrawResultEntity({
    required this.withdrawal,
    required this.balance,
    required this.transaction,
  });

  final double withdrawal;
  final double balance;
  final TransactionEntity transaction;

  @override
  List<Object?> get props => [withdrawal, balance, transaction];
}
