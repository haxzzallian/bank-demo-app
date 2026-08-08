import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_banner.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_card.dart';
import '../widgets/animated_aurora_background.dart';

/// Only collects what `POST /auth/signup` accepts: `{ phoneNumber, password }`.
/// The API has no name, email, or account-type field — do not add them back.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _validationError;

  // Account number == phone number, digits only, per API_RULES.md.
  static final RegExp _phonePattern = RegExp(r'^[0-9]{10,15}$');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);

    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (phoneNumber.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _validationError = 'Please complete all fields.');
      return;
    }

    if (!_phonePattern.hasMatch(phoneNumber)) {
      setState(() => _validationError = 'Enter a valid phone number.');
      return;
    }

    if (password.length < 8 || password.length > 128) {
      setState(
        () =>
            _validationError = 'Password must be between 8 and 128 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() => _validationError = 'Passwords do not match.');
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .register(phoneNumber: phoneNumber, password: password);

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final errorMessage = _validationError ?? authState.error;

    return Scaffold(
      body: AnimatedAuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(AppRoutes.login),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                      tooltip: 'Back to sign in',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Create account',
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Join BankDump',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your phone number is your account number — no paperwork, '
                  'no waiting.',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.call_outlined,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Create Password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirm Password',
                        controller: _confirmController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        AppErrorBanner(message: errorMessage),
                      ],
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Sign Up',
                        onPressed: _submit,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                        ),
                        child: Text(
                          'Sign in',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
