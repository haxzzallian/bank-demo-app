import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
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
      return Left(_mapDioError(error));
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
      return Left(_mapDioError(error));
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
      return Left(_mapDioError(error));
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

  Failure _mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure('Connection timed out. Please try again.');
    }

    if (error.error is SocketException) {
      return const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    }

    final response = error.response;
    if (response == null) {
      return const UnknownFailure('Something went wrong. Please try again.');
    }

    final statusCode = response.statusCode ?? 0;
    final message = _extractMessage(response.data) ?? error.message;

    switch (statusCode) {
      case 400:
      case 409:
        return ValidationFailure(message ?? 'Invalid request.');
      case 401:
      case 403:
        return UnauthorizedFailure(message ?? 'Authentication failed.');
      case 404:
        return NotFoundFailure(message ?? 'Not found.');
      default:
        if (statusCode >= 500) {
          return ServerFailure(message ?? 'Something went wrong on our end.');
        }
        return UnknownFailure(
          message ?? 'Something went wrong. Please try again.',
        );
    }
  }

  /// Extracts a user-facing message from the API's `ApiError` shape
  /// (`{ status, message, code, data }`), falling back to a couple of other
  /// common shapes in case the server ever deviates.
  String? _extractMessage(dynamic data) {
    try {
      if (data is String && data.isNotEmpty) return data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) return data['message'].toString();
        if (data['error'] != null) return data['error'].toString();
        if (data['errors'] is Map) {
          return (data['errors'] as Map).values.join(', ');
        }
        if (data['errors'] is List) {
          return (data['errors'] as List).join(', ');
        }
      }
    } catch (_) {
      // Fall through to null below.
    }
    return null;
  }
}
