import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_flavor.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/deposit/data/repositories/deposit_repository_impl.dart';
import '../../features/deposit/domain/repositories/deposit_repository.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transfer/data/repositories/transfer_repository_impl.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/withdraw/data/repositories/withdraw_repository_impl.dart';
import '../../features/withdraw/domain/repositories/withdraw_repository.dart';

final Provider<DioClient> dioClientProvider = Provider<DioClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  return DioClient(
    enableLogging: flavor != AppFlavor.prod,
    // A 401 means the stored token is dead — log out and let the router's
    // existing refreshListenable redirect to /login. This is a lazy `read`
    // inside a closure invoked later (at request-error time), not a watch
    // during this provider's own build, so it doesn't create a circular
    // dependency even though authControllerProvider itself depends on
    // dioClientProvider through authRepositoryProvider.
    onUnauthorized: () => ref.read(authControllerProvider.notifier).logout(),
  );
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
      return AuthRepositoryImpl(ref.watch(dioClientProvider));
    });

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
    );

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(ref.watch(dioClientProvider));
});

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return DepositRepositoryImpl(ref.watch(dioClientProvider));
});

final withdrawRepositoryProvider = Provider<WithdrawRepository>((ref) {
  return WithdrawRepositoryImpl(ref.watch(dioClientProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(dioClientProvider));
});
