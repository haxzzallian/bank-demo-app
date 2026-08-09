import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recipient_entity.dart';
import '../entities/transfer_result_entity.dart';

abstract class TransferRepository {
  Future<Either<Failure, List<RecipientEntity>>> getDirectory({
    int limit = 100,
    int offset = 0,
  });

  Future<Either<Failure, TransferResultEntity>> transfer({
    required String phoneNumber,
    required double amount,
  });
}
