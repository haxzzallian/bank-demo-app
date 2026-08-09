import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/idempotency.dart';
import '../models/deposit_result_model.dart';

abstract class DepositRemoteDataSource {
  Future<DepositResultModel> deposit({required double amount});
}

class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  DepositRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<DepositResultModel> deposit({required double amount}) async {
    final response = await _dioClient.dio.post(
      '/accounts/deposit',
      data: {'amount': amount},
      options: Options(headers: {'Idempotency-Key': generateIdempotencyKey()}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic> ||
        payload['data'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid deposit response.');
    }

    final data = payload['data'] as Map<String, dynamic>;
    if (data['deposited'] is! num ||
        data['balance'] is! num ||
        data['transaction'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid deposit response.');
    }

    return DepositResultModel.fromJson(data);
  }
}
