import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/withdraw_result_entity.dart';

abstract class WithdrawRepository {
  /// `POST /accounts/withdraw` — `amount` must be > 0; the API also
  /// validates sufficient balance server-side (400 on failure).
  Future<Either<Failure, WithdrawResultEntity>> withdraw({
    required double amount,
  });
}
