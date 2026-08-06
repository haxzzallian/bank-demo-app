import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/onboarding_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      title: 'Welcome to Bank Dump',
      subtitle:
          'A smarter way to manage local deliveries and customer requests.',
      icon: Icons.delivery_dining,
    ),
    _OnboardingStep(
      title: 'Track Every Order',
      subtitle:
          'Stay in control with real-time status updates for all deliveries.',
      icon: Icons.location_on,
    ),
    _OnboardingStep(
      title: 'Grow your business',
      subtitle:
          'Reach more customers while keeping your operations smooth and efficient.',
      icon: Icons.business_center,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStorage.instance.completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _onNext() {
    if (_currentPage == _steps.length - 1) {
      _completeOnboarding();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  // Brand
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withAlpha(40),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.savings, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('BankDump', style: AppTextStyles.brand),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withAlpha(
                        200,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hero card
                          Container(
                            height: 300,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.95),
                                  theme.colorScheme.secondary.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withAlpha(60),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(90),
                                ),
                                child: Icon(
                                  step.icon,
                                  size: 72,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Text(
                                  step.title,
                                  style: AppTextStyles.title,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  step.subtitle,
                                  style: AppTextStyles.subtitle,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final active = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: active ? 34 : 12,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withAlpha(30),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onNext,
                      child: Text(
                        _currentPage == _steps.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
