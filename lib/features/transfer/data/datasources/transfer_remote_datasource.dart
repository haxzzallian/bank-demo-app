import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/idempotency.dart';
import '../models/recipient_model.dart';
import '../models/transfer_result_model.dart';

abstract class TransferRemoteDataSource {
  Future<List<RecipientModel>> getDirectory({
    required int limit,
    required int offset,
  });

  Future<TransferResultModel> transfer({
    required String phoneNumber,
    required double amount,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  TransferRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<RecipientModel>> getDirectory({
    required int limit,
    required int offset,
  }) async {
    final response = await _dioClient.dio.get(
      '/accounts/list',
      queryParameters: {'limit': limit, 'offset': offset},
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic> || payload['data'] is! List) {
      throw const ServerException('Invalid directory response.');
    }

    return (payload['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map(RecipientModel.fromJson)
        .toList();
  }

  @override
  Future<TransferResultModel> transfer({
    required String phoneNumber,
    required double amount,
  }) async {
    final response = await _dioClient.dio.post(
      '/accounts/transfer',
      data: {'phoneNumber': phoneNumber, 'amount': amount},
      options: Options(headers: {'Idempotency-Key': generateIdempotencyKey()}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic> ||
        payload['data'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid transfer response.');
    }

    final data = payload['data'] as Map<String, dynamic>;
    if (data['sent'] is! num ||
        data['to'] == null ||
        data['balance'] is! num ||
        data['transaction'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid transfer response.');
    }

    return TransferResultModel.fromJson(data);
  }
}
