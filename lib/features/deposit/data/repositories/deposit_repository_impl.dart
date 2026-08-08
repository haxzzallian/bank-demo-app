import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/utils/idempotency.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/deposit_result_entity.dart';
import '../../domain/repositories/deposit_repository.dart';

class DepositRepositoryImpl implements DepositRepository {
  DepositRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, DepositResultEntity>> deposit({
    required double amount,
  }) async {
    if (amount <= 0) {
      return const Left(
        ValidationFailure('Enter an amount greater than zero.'),
      );
    }

    try {
      final response = await _dioClient.dio.post(
        '/accounts/deposit',
        data: {'amount': amount},
        options: Options(
          headers: {'Idempotency-Key': generateIdempotencyKey()},
        ),
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic> ||
          payload['data'] is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid deposit response.'));
      }

      final data = payload['data'] as Map<String, dynamic>;
      final deposited = (data['deposited'] as num?)?.toDouble();
      final balance = (data['balance'] as num?)?.toDouble();
      final transactionJson = data['transaction'];

      if (deposited == null ||
          balance == null ||
          transactionJson is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid deposit response.'));
      }

      return Right(
        DepositResultEntity(
          deposited: deposited,
          balance: balance,
          transaction: TransactionModel.fromJson(transactionJson).toEntity(),
        ),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
