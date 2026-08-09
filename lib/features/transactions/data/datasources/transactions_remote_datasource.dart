import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<({List<TransactionModel> items, PageMetaModel meta})> getTransactions({
    required int limit,
    required int offset,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  TransactionsRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<({List<TransactionModel> items, PageMetaModel meta})> getTransactions({
    required int limit,
    required int offset,
  }) async {
    final response = await _dioClient.dio.get(
      '/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic> || payload['data'] is! List) {
      throw const ServerException('Invalid transactions response.');
    }

    final items = (payload['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();

    final meta = payload['meta'] is Map<String, dynamic>
        ? PageMetaModel.fromJson(payload['meta'] as Map<String, dynamic>)
        : PageMetaModel(
            total: items.length,
            limit: limit,
            offset: offset,
            hasMore: false,
          );

    return (items: items, meta: meta);
  }
}
