import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/withdraw_result_entity.dart';
import '../../domain/repositories/withdraw_repository.dart';
import '../datasources/withdraw_remote_datasource.dart';

class WithdrawRepositoryImpl implements WithdrawRepository {
  WithdrawRepositoryImpl(this._remoteDataSource);

  final WithdrawRemoteDataSource _remoteDataSource;

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
      final result = await _remoteDataSource.withdraw(amount: amount);
      return Right(result.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }
}
