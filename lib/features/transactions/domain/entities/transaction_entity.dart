import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

/// Mirrors the API's `Transaction` shape exactly:
/// `{ id, type, amount, phoneNumber, counterparty, balance, note, created }`.
class TransactionEntity extends Equatable {
  const TransactionEntity({
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

  bool get isCredit => type == TransactionType.credit;

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    phoneNumber,
    counterparty,
    balance,
    note,
    created,
  ];
}

/// A page of transactions plus its pagination metadata, so callers (Phase 7's
/// full history screen) can extend pagination without a repository change.
class TransactionsPage extends Equatable {
  const TransactionsPage({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  final List<TransactionEntity> items;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  @override
  List<Object?> get props => [items, total, limit, offset, hasMore];
}
