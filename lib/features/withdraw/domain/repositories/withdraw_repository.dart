import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/withdraw_result_entity.dart';

abstract class WithdrawRepository {
  Future<Either<Failure, WithdrawResultEntity>> withdraw({
    required double amount,
  });
}
