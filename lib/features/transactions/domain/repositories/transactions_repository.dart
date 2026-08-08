import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionsRepository {
  /// `GET /transactions` — respects `limit`/`offset` per API_RULES.md.
  Future<Either<Failure, TransactionsPage>> getTransactions({
    int limit = 50,
    int offset = 0,
  });
}
