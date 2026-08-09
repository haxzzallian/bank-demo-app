import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/recipient_entity.dart';
import '../../domain/entities/transfer_result_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._remoteDataSource);

  final TransferRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<RecipientEntity>>> getDirectory({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final recipients = await _remoteDataSource.getDirectory(
        limit: limit,
        offset: offset,
      );
      return Right(recipients.map((model) => model.toEntity()).toList());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
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
      final result = await _remoteDataSource.transfer(
        phoneNumber: phoneNumber.trim(),
        amount: amount,
      );
      return Right(result.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }
}
