import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String phoneNumber,
    required String password,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<AuthResponseModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/login',
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    return _parseAuthResponse(response.data, 'login');
  }

  @override
  Future<AuthResponseModel> register({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/signup',
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    return _parseAuthResponse(response.data, 'signup');
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.dio.get('/auth/me');

    final payload = response.data;
    if (payload is! Map<String, dynamic> ||
        payload['data'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid account response.');
    }

    return UserModel.fromJson(payload['data'] as Map<String, dynamic>);
  }

  AuthResponseModel _parseAuthResponse(dynamic payload, String action) {
    if (payload is! Map<String, dynamic> ||
        payload['data'] is! Map<String, dynamic>) {
      throw ServerException('Invalid $action response.');
    }

    final data = payload['data'] as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw const ServerException('Authentication token is missing.');
    }
    if (data['user'] is! Map<String, dynamic>) {
      throw const ServerException('Invalid account response.');
    }

    return AuthResponseModel.fromJson(data);
  }
}
