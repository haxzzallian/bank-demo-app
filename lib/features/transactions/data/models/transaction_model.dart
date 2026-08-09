import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.phoneNumber,
    required this.counterparty,
    required this.balance,
    required this.note,
    required this.created,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String phoneNumber;
  final String? counterparty;
  final double balance;
  final String? note;
  final DateTime created;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] == 'debit'
          ? TransactionType.debit
          : TransactionType.credit,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      counterparty: json['counterparty']?.toString(),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      note: json['note']?.toString(),
      created:
          DateTime.tryParse(json['created']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type,
      amount: amount,
      phoneNumber: phoneNumber,
      counterparty: counterparty,
      balance: balance,
      note: note,
      created: created,
    );
  }
}

class PageMetaModel {
  const PageMetaModel({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  factory PageMetaModel.fromJson(Map<String, dynamic> json) {
    return PageMetaModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
