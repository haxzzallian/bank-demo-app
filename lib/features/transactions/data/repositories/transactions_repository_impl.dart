import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._remoteDataSource);

  final TransactionsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, TransactionsPage>> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await _remoteDataSource.getTransactions(
        limit: limit,
        offset: offset,
      );

      return Right(
        TransactionsPage(
          items: result.items.map((model) => model.toEntity()).toList(),
          total: result.meta.total,
          limit: result.meta.limit,
          offset: result.meta.offset,
          hasMore: result.meta.hasMore,
        ),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }
}
