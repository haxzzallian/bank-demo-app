import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/deposit_result_entity.dart';

abstract class DepositRepository {
  /// `POST /accounts/deposit` — `amount` must be > 0 per API_RULES.md.
  Future<Either<Failure, DepositResultEntity>> deposit({
    required double amount,
  });
}
