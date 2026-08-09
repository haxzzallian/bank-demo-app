import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
