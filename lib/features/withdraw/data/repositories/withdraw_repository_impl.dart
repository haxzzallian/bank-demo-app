import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/utils/idempotency.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/entities/withdraw_result_entity.dart';
import '../../domain/repositories/withdraw_repository.dart';

class WithdrawRepositoryImpl implements WithdrawRepository {
  WithdrawRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, WithdrawResultEntity>> withdraw({
    required double amount,
  }) async {
    if (amount <= 0) {
      return const Left(
        ValidationFailure('Enter an amount greater than zero.'),
      );
    }

    try {
      final response = await _dioClient.dio.post(
        '/accounts/withdraw',
        data: {'amount': amount},
        options: Options(
          headers: {'Idempotency-Key': generateIdempotencyKey()},
        ),
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic> ||
          payload['data'] is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid withdrawal response.'));
      }

      final data = payload['data'] as Map<String, dynamic>;
      final withdrawal = (data['withdrawal'] as num?)?.toDouble();
      final balance = (data['balance'] as num?)?.toDouble();
      final transactionJson = data['transaction'];

      if (withdrawal == null ||
          balance == null ||
          transactionJson is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid withdrawal response.'));
      }

      return Right(
        WithdrawResultEntity(
          withdrawal: withdrawal,
          balance: balance,
          transaction: TransactionModel.fromJson(transactionJson).toEntity(),
        ),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
