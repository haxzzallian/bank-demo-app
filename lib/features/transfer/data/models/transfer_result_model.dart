import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/transfer_result_entity.dart';

class TransferResultModel {
  const TransferResultModel({
    required this.sent,
    required this.to,
    required this.balance,
    required this.transaction,
  });

  final double sent;
  final String to;
  final double balance;
  final TransactionModel transaction;

  factory TransferResultModel.fromJson(Map<String, dynamic> json) {
    return TransferResultModel(
      sent: (json['sent'] as num?)?.toDouble() ?? 0,
      to: json['to']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      transaction: TransactionModel.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
    );
  }

  TransferResultEntity toEntity() {
    return TransferResultEntity(
      sent: sent,
      to: to,
      balance: balance,
      transaction: transaction.toEntity(),
    );
  }
}
