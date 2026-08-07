import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isAuthenticated, isLoading, user, error];
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> login({required String phoneNumber, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String accountType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      accountType: accountType,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> logout() async {
    await TokenStorage.instance.clearToken();
    state = const AuthState();
  }
}
