import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_flavor.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/deposit/data/datasources/deposit_remote_datasource.dart';
import '../../features/deposit/data/repositories/deposit_repository_impl.dart';
import '../../features/deposit/domain/repositories/deposit_repository.dart';
import '../../features/transactions/data/datasources/transactions_remote_datasource.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transfer/data/datasources/transfer_remote_datasource.dart';
import '../../features/transfer/data/repositories/transfer_repository_impl.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/withdraw/data/datasources/withdraw_remote_datasource.dart';
import '../../features/withdraw/data/repositories/withdraw_repository_impl.dart';
import '../../features/withdraw/domain/repositories/withdraw_repository.dart';

final Provider<DioClient> dioClientProvider = Provider<DioClient>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  return DioClient(
    enableLogging: flavor != AppFlavor.prod,
    onUnauthorized: () => ref.read(authControllerProvider.notifier).logout(),
  );
});

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
      return AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
    });

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
      return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
    });

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
      (ref) => AuthController(ref.watch(authRepositoryProvider)),
    );

final transactionsRemoteDataSourceProvider =
    Provider<TransactionsRemoteDataSource>((ref) {
      return TransactionsRemoteDataSourceImpl(ref.watch(dioClientProvider));
    });

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(
    ref.watch(transactionsRemoteDataSourceProvider),
  );
});

final depositRemoteDataSourceProvider = Provider<DepositRemoteDataSource>((
  ref,
) {
  return DepositRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return DepositRepositoryImpl(ref.watch(depositRemoteDataSourceProvider));
});

final withdrawRemoteDataSourceProvider = Provider<WithdrawRemoteDataSource>((
  ref,
) {
  return WithdrawRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final withdrawRepositoryProvider = Provider<WithdrawRepository>((ref) {
  return WithdrawRepositoryImpl(ref.watch(withdrawRemoteDataSourceProvider));
});

final transferRemoteDataSourceProvider = Provider<TransferRemoteDataSource>((
  ref,
) {
  return TransferRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(transferRemoteDataSourceProvider));
});
