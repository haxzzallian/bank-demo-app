import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Overrides Flutter's default red "error screen" with a friendlier
/// fallback. Per AI_INSTRUCTIONS.md's "no crashes": an unexpected
/// widget-build error should never show Flutter's default screen (which
/// looks broken to a user and, worse, can print raw stack traces) — this
/// swaps in a plain, on-brand fallback instead.
///
/// [showDetails] mirrors the existing dev/staging-vs-prod gating already
/// used for request logging (see DioClient) — the exception is only shown
/// on-screen outside prod.
void configureErrorHandling({required bool showDetails}) {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _FriendlyErrorScreen(details: details, showDetails: showDetails);
  };
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen({
    required this.details,
    required this.showDetails,
  });

  final FlutterErrorDetails details;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    // No Scaffold/MaterialApp ancestor is guaranteed here — this can render
    // deep inside any broken subtree — so it's built on bare `Material`.
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                if (showDetails) ...[
                  const SizedBox(height: 16),
                  Text(
                    details.exceptionAsString(),
                    style: AppTextStyles.caption.copyWith(
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
