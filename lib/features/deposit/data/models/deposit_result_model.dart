import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/deposit_result_entity.dart';

class DepositResultModel {
  const DepositResultModel({
    required this.deposited,
    required this.balance,
    required this.transaction,
  });

  final double deposited;
  final double balance;
  final TransactionModel transaction;

  factory DepositResultModel.fromJson(Map<String, dynamic> json) {
    return DepositResultModel(
      deposited: (json['deposited'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transaction: TransactionModel.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
    );
  }

  DepositResultEntity toEntity() {
    return DepositResultEntity(
      deposited: deposited,
      balance: balance,
      transaction: transaction.toEntity(),
    );
  }
}
