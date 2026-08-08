import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/deposit/presentation/pages/deposit_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transfer/presentation/pages/transfer_page.dart';
import '../../features/withdraw/presentation/pages/withdraw_page.dart';
import '../di/injection.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// Turns `authControllerProvider` changes into `GoRouter`'s `refreshListenable`
/// signal, so a login/logout/session-check re-evaluates `redirect` on the
/// *current* router instance instead of tearing down and recreating GoRouter
/// itself. Recreating GoRouter resets its navigation stack to
/// `initialLocation`, which would replay `SplashPage.initState()` — which
/// calls `checkAuthStatus()` — which changes auth state again — recreating
/// GoRouter again, forever. Watching the provider directly inside
/// `appRouterProvider`'s build function (the previous approach) hit exactly
/// that loop.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

/// A subtle, consistent fade + slight-slide transition used for every route
/// (replacing the platform-default transition) — a small, self-contained
/// premium touch that only affects how a page's widget builds, not the
/// redirect/refresh logic above.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(fade),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadePage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadePage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _fadePage(state, const SignUpPage()),
      ),
      // Full-screen flow pushed on top of the shell — not a tab, so it
      // doesn't sit inside StatefulShellRoute below.
      GoRoute(
        path: AppRoutes.deposit,
        pageBuilder: (context, state) => _fadePage(state, const DepositPage()),
      ),
      GoRoute(
        path: AppRoutes.withdraw,
        pageBuilder: (context, state) => _fadePage(state, const WithdrawPage()),
      ),
      GoRoute(
        path: AppRoutes.transfer,
        pageBuilder: (context, state) => _fadePage(state, const TransferPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) =>
                    _fadePage(state, const HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.transactions,
                pageBuilder: (context, state) =>
                    _fadePage(state, const TransactionsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                pageBuilder: (context, state) =>
                    _fadePage(state, const AnalyticsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) =>
                    _fadePage(state, const ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      final isSignupRoute = state.matchedLocation == AppRoutes.signup;
      final isSplashRoute = state.matchedLocation == AppRoutes.splash;

      if (isSplashRoute) {
        return null;
      }

      if (!isAuthenticated &&
          !isLoginRoute &&
          !isOnboardingRoute &&
          !isSignupRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isLoginRoute) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});
