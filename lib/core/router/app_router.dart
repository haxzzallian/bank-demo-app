import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../di/injection.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile scaffold'))),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authController.isAuthenticated;
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
