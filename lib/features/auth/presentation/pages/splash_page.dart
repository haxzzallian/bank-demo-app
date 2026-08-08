import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/onboarding_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/animated_aurora_background.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _initializeApp();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final entrance = Future<void>.delayed(const Duration(milliseconds: 1100));
    final hasOnboarded = await OnboardingStorage.instance
        .hasCompletedOnboarding();
    // Hydrates AuthController's state from the persisted token *before* the
    // router makes its first redirect decision — otherwise a valid session
    // still reads as unauthenticated and gets bounced back to login on the
    // next router rebuild.
    await ref.read(authControllerProvider.notifier).checkAuthStatus();
    await entrance;

    if (!mounted) return;

    if (!hasOnboarded) {
      context.go(AppRoutes.onboarding);
      return;
    }

    final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
    if (isAuthenticated) {
      context.go(AppRoutes.home);
      return;
    }

    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedAuroraBackground(
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.cta, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cta.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/images/bankDumpLogo.png'),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'BankDump',
                        style: AppTextStyles.brand.copyWith(
                          color: AppColors.surface,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Send, save, and track your money — all in one place.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.surface.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 44),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.surface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
