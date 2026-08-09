import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

class DepositResultEntity extends Equatable {
  const DepositResultEntity({
    required this.deposited,
    required this.balance,
    required this.transaction,
  });

  final double deposited;
  final double balance;
  final TransactionEntity transaction;

  @override
  List<Object?> get props => [deposited, balance, transaction];
}
