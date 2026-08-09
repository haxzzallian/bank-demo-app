import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/onboarding_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/press_scale.dart';
import '../widgets/animated_aurora_background.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Send money in seconds',
      subtitle:
          'Transfer to any BankDump user instantly with just their phone '
          'number. No fees, no waiting.',
      icon: Icons.send_rounded,
      gradient: [AppColors.primary, AppColors.secondary],
      topChipLabel: 'To',
      topChipValue: '0810 •••• 35',
      bottomChipLabel: 'Sent',
      bottomChipValue: '₦25,000',
    ),
    OnboardingSlideData(
      title: 'Watch your money grow',
      subtitle:
          'Deposit, withdraw, and see exactly where your money goes with '
          'clear, real-time analytics.',
      icon: Icons.insights_rounded,
      gradient: [AppColors.secondary, AppColors.cta],
      topChipLabel: 'Balance',
      topChipValue: '₦248,500',
      bottomChipLabel: 'This month',
      bottomChipValue: '+18.4%',
    ),
    OnboardingSlideData(
      title: 'Bank-grade security, always',
      subtitle:
          'Every login and transaction is protected with secure '
          'authentication and encryption.',
      icon: Icons.verified_user_rounded,
      gradient: [AppColors.cta, AppColors.primary],
      topChipLabel: 'Login',
      topChipValue: 'Verified',
      bottomChipLabel: 'Encryption',
      bottomChipValue: '256-bit',
    ),
  ];

  int _currentPage = 0;
  Timer? _autoScrollTimer;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_entranceFade);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStorage.instance.completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  void _onNext() {
    if (_currentPage == _slides.length - 1) {
      _completeOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: AnimatedAuroraBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _entranceFade,
            child: SlideTransition(
              position: _entranceSlide,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _slides.length,
                        itemBuilder: (context, index) => _buildSlide(index),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIndicator(),
                    const SizedBox(height: 24),
                    _buildActions(isLastPage),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.cta, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.cta.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/icons/bankDumpIcon.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'BankDump',
            style: AppTextStyles.brand.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        TextButton(
          onPressed: _completeOnboarding,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white.withValues(alpha: 0.75),
          ),
          child: const Text('Skip'),
        ),
      ],
    );
  }

  Widget _buildSlide(int index) {
    final slide = _slides[index];
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = index.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          page = _pageController.page ?? _currentPage.toDouble();
        }
        final delta = (page - index).clamp(-1.0, 1.0);
        return Opacity(
          opacity: (1 - delta.abs()).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, delta * 32),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final illustrationSize = math.min(
            constraints.maxWidth * 0.82,
            constraints.maxHeight * 0.46,
          );
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: illustrationSize,
                      height: illustrationSize,
                      child: OnboardingIllustration(step: slide),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slide.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final active = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.cta, AppColors.secondary],
                  )
                : null,
            color: active ? null : Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildActions(bool isLastPage) {
    return Row(
      children: [
        Expanded(
          child: PressScale(
            onTap: _completeOnboarding,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: PressScale(
            onTap: _onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cta, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cta.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Text(
                isLastPage ? 'Get Started' : 'Continue',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
