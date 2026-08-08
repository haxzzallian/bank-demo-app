import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<Either<Failure, TransactionsPage>> getTransactions({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/transactions',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final payload = response.data;
      if (payload is! Map<String, dynamic> || payload['data'] is! List) {
        return const Left(ServerFailure('Invalid transactions response.'));
      }

      final items = (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => TransactionModel.fromJson(json).toEntity())
          .toList();

      final meta = payload['meta'] is Map<String, dynamic>
          ? PageMetaModel.fromJson(payload['meta'] as Map<String, dynamic>)
          : PageMetaModel(
              total: items.length,
              limit: limit,
              offset: offset,
              hasMore: false,
            );

      return Right(
        TransactionsPage(
          items: items,
          total: meta.total,
          limit: meta.limit,
          offset: meta.offset,
          hasMore: meta.hasMore,
        ),
      );
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }
}
