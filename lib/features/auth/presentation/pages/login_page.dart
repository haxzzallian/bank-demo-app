import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: 'demo@bankdump.app');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/icons/logo.png', width: 46),
                  const SizedBox(width: 14),
                  Text('BankDump', style: AppTextStyles.brand),
                ],
              ),
              const SizedBox(height: 32),
              Text('Welcome back', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage orders, deliveries, and merchant tools in one place.',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      if (authState.error != null)
                        Text(
                          authState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Sign In',
                        onPressed: _submit,
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Use the demo credentials to continue',
                  style: AppTextStyles.caption,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.signup),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
