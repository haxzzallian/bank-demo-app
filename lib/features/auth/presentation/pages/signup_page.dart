import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/di/injection.dart';
import '../providers/auth_controller.dart';

enum AccountType { customer, agent }

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+234');
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showForm = false;
  AccountType _selectedType = AccountType.customer;
  String? _validationError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final business = _businessController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        business.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _validationError = 'Please complete all required fields.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _validationError = 'Enter a valid email address.');
      return;
    }

    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phoneNumber)) {
      setState(() => _validationError = 'Enter a valid phone number.');
      return;
    }

    if (password.length < 8) {
      setState(
        () => _validationError = 'Password must be at least 8 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() => _validationError = 'Passwords do not match.');
      return;
    }

    final accountType = _selectedType == AccountType.customer
        ? 'Customer'
        : 'Agent';
    final fullName = '$firstName $lastName';

    await ref
        .read(authControllerProvider.notifier)
        .register(
          name: fullName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          accountType: accountType,
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

    Widget accountTypeCard(String label, AccountType type) {
      final selected = _selectedType == type;
      return GestureDetector(
        onTap: () => setState(() {
          _selectedType = type;
          _showForm = true;
          _validationError = null;
        }),
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cta,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withAlpha(24), blurRadius: 8)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.title.copyWith(
                color: Colors.black,
                fontSize: 28,
              ),
            ),
          ),
        ),
      );
    }

    final leftPane = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Type', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Choose the right onboarding path to access merchant tools, payouts, and settlement insights.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 24),
          accountTypeCard('Customer', AccountType.customer),
          accountTypeCard('Agent', AccountType.agent),
        ],
      ),
    );

    final form = Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create an Account', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'Register your merchant profile and access payouts, settlements, and sales insights in one place.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          AppTextField(label: 'Business Name', controller: _businessController),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Create Password',
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Confirm Password',
            controller: _confirmController,
            obscureText: true,
          ),
          const SizedBox(height: 18),
          if (_validationError != null || authState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _validationError ?? authState.error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          AppButton(
            label: 'Sign Up',
            onPressed: _submit,
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => setState(() {
                _showForm = false;
                _validationError = null;
              }),
              child: const Text('Back to account type'),
            ),
          ),
        ],
      ),
    );

    if (!_showForm) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.go(AppRoutes.login),
          ),
          title: const Text('Create an account'),
          elevation: 0,
        ),
        body: SafeArea(child: SingleChildScrollView(child: leftPane)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            setState(() {
              _showForm = false;
              _validationError = null;
            });
          },
        ),
        title: const Text('Create an account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return Row(
                children: [
                  Flexible(flex: 4, child: leftPane),
                  const VerticalDivider(width: 1),
                  Flexible(flex: 6, child: SingleChildScrollView(child: form)),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: form,
            );
          },
        ),
      ),
    );
  }
}
