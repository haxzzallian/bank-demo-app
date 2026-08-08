import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'press_scale.dart';

/// The app's primary CTA — a gradient pill with tactile press feedback,
/// matching the language established on the splash/onboarding screens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading;

    return PressScale(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.cta, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.cta.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
