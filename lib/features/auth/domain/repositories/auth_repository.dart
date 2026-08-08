import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String phoneNumber,
    required String password,
  });

  /// Fetches the currently authenticated user via `GET /auth/me`. Used to
  /// hydrate session state on cold start and to refresh balance elsewhere.
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
