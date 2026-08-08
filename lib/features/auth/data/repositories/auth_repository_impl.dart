import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dioClient);

  final DioClient _dioClient;

  // Account number == phone number, digits only, per API_RULES.md.
  final RegExp _phonePattern = RegExp(r'^[0-9]{10,15}$');

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedPassword = password.trim();

    final validationError = _validateCredentials(
      trimmedPhoneNumber,
      trimmedPassword,
    );
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }

    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'phoneNumber': trimmedPhoneNumber, 'password': trimmedPassword},
      );

      return await _handleAuthResponse(response);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String phoneNumber,
    required String password,
  }) async {
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedPassword = password.trim();

    final validationError = _validateCredentials(
      trimmedPhoneNumber,
      trimmedPassword,
    );
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }

    try {
      final response = await _dioClient.dio.post(
        '/auth/signup',
        data: {'phoneNumber': trimmedPhoneNumber, 'password': trimmedPassword},
      );

      return await _handleAuthResponse(response);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/auth/me');

      final payload = response.data;
      if (payload is! Map<String, dynamic> ||
          payload['data'] is! Map<String, dynamic>) {
        return const Left(ServerFailure('Invalid account response.'));
      }

      final userModel = UserModel.fromJson(
        payload['data'] as Map<String, dynamic>,
      );
      return Right(userModel.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    }
  }

  /// Mirrors the `Credentials` schema: `phoneNumber` digits-only,
  /// `password` 8–128 chars.
  String? _validateCredentials(String phoneNumber, String password) {
    if (phoneNumber.isEmpty || password.isEmpty) {
      return 'Phone number and password are required.';
    }
    if (!_phonePattern.hasMatch(phoneNumber)) {
      return 'Enter a valid phone number.';
    }
    if (password.length < 8 || password.length > 128) {
      return 'Password must be between 8 and 128 characters.';
    }
    return null;
  }

  Future<Either<Failure, UserEntity>> _handleAuthResponse(
    Response response,
  ) async {
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const Left(ServerFailure('Invalid server response.'));
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      return const Left(ServerFailure('Invalid authentication response.'));
    }

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      return const Left(ServerFailure('Authentication token is missing.'));
    }

    await TokenStorage.instance.saveToken(token);

    if (data['user'] is! Map<String, dynamic>) {
      return const Left(ServerFailure('Invalid account response.'));
    }

    final userModel = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return Right(userModel.toEntity());
  }
}
