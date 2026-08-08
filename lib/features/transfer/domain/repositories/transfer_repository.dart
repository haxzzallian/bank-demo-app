import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recipient_entity.dart';
import '../entities/transfer_result_entity.dart';

abstract class TransferRepository {
  /// `GET /accounts/list` — the recipient directory. No server-side search;
  /// callers filter the fetched page client-side.
  Future<Either<Failure, List<RecipientEntity>>> getDirectory({
    int limit = 100,
    int offset = 0,
  });

  /// `POST /accounts/transfer` — `amount` must be > 0; the API also
  /// validates sufficient balance, recipient existence, and rejects
  /// transfers to self.
  Future<Either<Failure, TransferResultEntity>> transfer({
    required String phoneNumber,
    required double amount,
  });
}
