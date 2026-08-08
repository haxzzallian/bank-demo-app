import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/utils/idempotency.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/recipient_entity.dart';
import '../../domain/entities/transfer_result_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../models/recipient_model.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, List<RecipientEntity>>> getDirectory({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/accounts/list',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic> || payload['data'] is! List) {
        return const Left(ServerFailure('Invalid directory response.'));
      }

      final recipients = (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => RecipientModel.fromJson(json).toEntity())
          .toList();

      return Right(recipients);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  Future<Either<Failure, TransferResultEntity>> transfer({
    required String phoneNumber,
    required double amount,
  }) async {
    if (amount <= 0) {
      return const Left(
        ValidationFailure('Enter an amount greater than zero.'),
      );
    }
    if (phoneNumber.trim().isEmpty) {
      return const Left(ValidationFailure('Select a recipient.'));
    }

    try {
      final response = await _dioClient.dio.post(
        '/accounts/transfer',
        data: {'phoneNumber': phoneNumber.trim(), 'amount': amount},
        options: Options(
          headers: {'Idempotency-Key': generateIdempotencyKey()},
        ),
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic> ||
          payload['data'] is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid transfer response.'));
      }

      final data = payload['data'] as Map<String, dynamic>;
      final sent = (data['sent'] as num?)?.toDouble();
      final to = data['to']?.toString();
      final balance = (data['balance'] as num?)?.toDouble();
      final transactionJson = data['transaction'];

      if (sent == null ||
          to == null ||
          balance == null ||
          transactionJson is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid transfer response.'));
      }

      return Right(
        TransferResultEntity(
          sent: sent,
          to: to,
          balance: balance,
          transaction: TransactionModel.fromJson(transactionJson).toEntity(),
        ),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
