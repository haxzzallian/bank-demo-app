import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.isLoading = false,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    UserEntity? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, isLoading, user, error];
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final hasToken = await TokenStorage.instance.hasToken();
    if (!hasToken) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
      return;
    }

    final result = await _repository.getCurrentUser();

    result.fold(
      (failure) async {
        await TokenStorage.instance.clearToken();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
        );
      },
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> register({
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.register(
      phoneNumber: phoneNumber,
      password: password,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          isLoading: false,
          user: user,
          error: null,
        );
      },
    );
  }

  Future<void> logout() async {
    await TokenStorage.instance.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
