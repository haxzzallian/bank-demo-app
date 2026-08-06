import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      return const Left(ValidationFailure('Email and password are required.'));
    }

    final userModel = UserModel(
      id: 'demo-user',
      name: 'BankDump Guest',
      email: email,
    );

    return Right(userModel.toEntity());
  }
}
