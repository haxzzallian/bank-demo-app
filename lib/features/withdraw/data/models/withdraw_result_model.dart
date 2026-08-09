import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/withdraw_result_entity.dart';

class WithdrawResultModel {
  const WithdrawResultModel({
    required this.withdrawal,
    required this.balance,
    required this.transaction,
  });

  final double withdrawal;
  final double balance;
  final TransactionModel transaction;

  factory WithdrawResultModel.fromJson(Map<String, dynamic> json) {
    return WithdrawResultModel(
      withdrawal: (json['withdrawal'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transaction: TransactionModel.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
    );
  }

  WithdrawResultEntity toEntity() {
    return WithdrawResultEntity(
      withdrawal: withdrawal,
      balance: balance,
      transaction: transaction.toEntity(),
    );
  }
}
