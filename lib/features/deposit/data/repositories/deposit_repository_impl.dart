import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/deposit_result_entity.dart';
import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_remote_datasource.dart';

class DepositRepositoryImpl implements DepositRepository {
  DepositRepositoryImpl(this._remoteDataSource);

  final DepositRemoteDataSource _remoteDataSource;

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
      final result = await _remoteDataSource.deposit(amount: amount);
      return Right(result.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }
}
