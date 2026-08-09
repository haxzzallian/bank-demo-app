import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

class TransferResultEntity extends Equatable {
  const TransferResultEntity({
    required this.sent,
    required this.to,
    required this.balance,
    required this.transaction,
  });

  final double sent;
  final String to;
  final double balance;
  final TransactionEntity transaction;

  @override
  List<Object?> get props => [sent, to, balance, transaction];
}
