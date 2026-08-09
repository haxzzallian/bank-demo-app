import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/deposit_result_entity.dart';

abstract class DepositRepository {
  Future<Either<Failure, DepositResultEntity>> deposit({
    required double amount,
  });
}
