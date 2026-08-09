import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

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
      final result = await _remoteDataSource.login(
        phoneNumber: trimmedPhoneNumber,
        password: trimmedPassword,
      );
      await TokenStorage.instance.saveToken(result.token);
      return Right(result.user.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
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
      final result = await _remoteDataSource.register(
        phoneNumber: trimmedPhoneNumber,
        password: trimmedPassword,
      );
      await TokenStorage.instance.saveToken(result.token);
      return Right(result.user.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user.toEntity());
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

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
}
