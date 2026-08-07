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

  final RegExp _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');
  final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedPassword = password.trim();

    if (trimmedPhoneNumber.isEmpty || trimmedPassword.isEmpty) {
      return const Left(
        ValidationFailure('Phone number and password are required.'),
      );
    }

    if (!_phonePattern.hasMatch(trimmedPhoneNumber)) {
      return const Left(ValidationFailure('Enter a valid phone number.'));
    }

    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {'phoneNumber': trimmedPhoneNumber, 'password': trimmedPassword},
      );

      return await _handleAuthResponse(
        response,
        fallbackEmail: '',
        fallbackName: trimmedPhoneNumber,
      );
    } on DioError catch (error) {
      return Left(_mapDioError(error));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String accountType,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedPassword = password.trim();

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPhoneNumber.isEmpty ||
        trimmedPassword.isEmpty) {
      return const Left(ValidationFailure('All fields are required.'));
    }

    if (!_emailPattern.hasMatch(trimmedEmail)) {
      return const Left(ValidationFailure('Enter a valid email address.'));
    }

    if (!_phonePattern.hasMatch(trimmedPhoneNumber)) {
      return const Left(ValidationFailure('Enter a valid phone number.'));
    }

    if (trimmedPassword.length < 8) {
      return const Left(
        ValidationFailure('Password must be at least 8 characters.'),
      );
    }

    try {
      final response = await _dioClient.dio.post(
        '/auth/signup',
        data: {'phoneNumber': trimmedPhoneNumber, 'password': trimmedPassword},
      );

      return await _handleAuthResponse(
        response,
        fallbackEmail: trimmedEmail,
        fallbackName: trimmedName,
      );
    } on DioError catch (error) {
      return Left(_mapDioError(error));
    }
  }

  Future<Either<Failure, UserEntity>> _handleAuthResponse(
    Response response, {
    required String fallbackEmail,
    required String fallbackName,
  }) async {
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

    final userJson = <String, dynamic>{};
    if (data['user'] is Map<String, dynamic>) {
      userJson.addAll(data['user'] as Map<String, dynamic>);
    }
    userJson['email'] = userJson['email'] ?? fallbackEmail;
    userJson['name'] = userJson['name'] ?? fallbackName;

    final userModel = UserModel.fromJson(userJson);
    return Right(userModel.toEntity());
  }

  Failure _mapDioError(DioError error) {
    if (error.type == DioErrorType.connectionTimeout ||
        error.type == DioErrorType.sendTimeout ||
        error.type == DioErrorType.receiveTimeout) {
      return const NetworkFailure('Connection timed out. Please try again.');
    }

    if (error.error is SocketException) {
      return const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode ?? 0;

      // Attempt to extract a meaningful message from multiple common shapes.
      String extractMessage(dynamic data) {
        try {
          if (data == null) return 'Authentication failed.';
          if (data is String) return data;
          if (data is Map<String, dynamic>) {
            if (data['message'] != null) return data['message'].toString();
            if (data['error'] != null) return data['error'].toString();
            if (data['errors'] != null) {
              final errs = data['errors'];
              if (errs is Map) return errs.values.join(', ');
              if (errs is List) return errs.join(', ');
            }
            if (data['data'] is Map && data['data']['message'] != null) {
              return data['data']['message'].toString();
            }
          }
          return 'Authentication failed.';
        } catch (_) {
          return 'Authentication failed.';
        }
      }

      final String message =
          extractMessage(response.data) ??
          (error.message ?? 'Authentication failed.');

      if (statusCode == 401) {
        return UnauthorizedFailure(message);
      }
      if (statusCode == 404) {
        return NotFoundFailure(message);
      }
      return ServerFailure(message);
    }

    return UnknownFailure('Something went wrong. Please try again.');
  }
}
