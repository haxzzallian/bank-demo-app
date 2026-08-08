import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted glass container used to house content over dark/gradient
/// backgrounds (e.g. `AnimatedAuroraBackground`), per UI_GUIDELINES's
/// "glass effects where appropriate".
class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: child,
        ),
      ),
    );
  }
}
