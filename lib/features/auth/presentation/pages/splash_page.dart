import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/onboarding_storage.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final hasOnboarded = await OnboardingStorage.instance
        .hasCompletedOnboarding();
    final hasToken = await TokenStorage.instance.hasToken();

    if (!mounted) return;

    if (!hasOnboarded) {
      context.go(AppRoutes.onboarding);
      return;
    }

    if (hasToken) {
      context.go(AppRoutes.home);
      return;
    }

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withAlpha(224),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo.png', width: 48),
                const SizedBox(width: 14),
                Text(
                  'BankDump',
                  style: AppTextStyles.brand.copyWith(color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Deliver faster. Manage smarter.',
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Local logistics made easy for merchants and couriers.',
              style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
