import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/idempotency.dart';
import '../models/withdraw_result_model.dart';

abstract class WithdrawRemoteDataSource {
  Future<WithdrawResultModel> withdraw({required double amount});
}

class WithdrawRemoteDataSourceImpl implements WithdrawRemoteDataSource {
  WithdrawRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<WithdrawResultModel> withdraw({required double amount}) async {
    final response = await _dioClient.dio.post(
      '/accounts/withdraw',
      data: {'amount': amount},
      options: Options(headers: {'Idempotency-Key': generateIdempotencyKey()}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic> ||
        payload['data'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid withdrawal response.');
    }

    final data = payload['data'] as Map<String, dynamic>;
    if (data['withdrawal'] is! num ||
        data['balance'] is! num ||
        data['transaction'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid withdrawal response.');
    }

    return WithdrawResultModel.fromJson(data);
  }
}
