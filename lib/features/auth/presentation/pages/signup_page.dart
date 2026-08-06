import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

enum AccountType { customer, agent }

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+234');
  final _hostelController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  AccountType _selectedType = AccountType.customer;
  bool _showForm = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _hostelController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    await TokenStorage.instance.saveToken('demo-token');
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (_showForm) {
              setState(() => _showForm = false);
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: const Text('Create an account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            final padding = const EdgeInsets.all(24.0);

            Widget accountTypeCard(String label, AccountType type) {
              final selected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedType = type;
                  _showForm = true;
                }),
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cta,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(24),
                              blurRadius: 8,
                            ),
                          ]
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
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Type', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to get started- shop as a customer or sign up as an agent to earn',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 24),
                  accountTypeCard('Customer', AccountType.customer),
                  accountTypeCard('Agent', AccountType.agent),
                ],
              ),
            );

            final form = Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create an Account', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account to get started and start shopping, and managing it all in one place.',
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
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Hostel', controller: _hostelController),
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
                  AppButton(
                    label: 'Sign Up',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showForm = false),
                      child: const Text('Back to account type'),
                    ),
                  ),
                ],
              ),
            );

            if (!_showForm) {
              return leftPane;
            }

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
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [if (!_showForm) leftPane, if (_showForm) form],
              ),
            );
          },
        ),
      ),
    );
  }
}
