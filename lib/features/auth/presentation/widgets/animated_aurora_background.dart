import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A slow, continuously drifting gradient backdrop with soft blurred orbs.
///
/// Used behind the splash and onboarding screens to give a premium, "alive"
/// first impression without being distracting — motion is subtle and never
/// draws attention away from the foreground content.
class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({super.key, this.child});

  final Widget? child;

  @override
  State<AnimatedAuroraBackground> createState() =>
      _AnimatedAuroraBackgroundState();
}

class _AnimatedAuroraBackgroundState extends State<AnimatedAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFF13245A),
                AppColors.darkBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * math.pi;
            return Stack(
              children: [
                _orb(
                  alignment: Alignment(
                    0.85 + 0.15 * math.sin(t),
                    -0.9 + 0.12 * math.cos(t),
                  ),
                  size: 260,
                  color: AppColors.cta,
                ),
                _orb(
                  alignment: Alignment(
                    -0.9 + 0.14 * math.cos(t * 0.8),
                    0.95 + 0.10 * math.sin(t * 0.8),
                  ),
                  size: 300,
                  color: AppColors.secondary,
                ),
                _orb(
                  alignment: Alignment(
                    0.18 * math.sin(t * 0.6 + 1.4),
                    0.18 * math.cos(t * 0.6 + 1.4),
                  ),
                  size: 220,
                  color: AppColors.secondary,
                  opacity: 0.14,
                ),
              ],
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }

  Widget _orb({
    required Alignment alignment,
    required double size,
    required Color color,
    double opacity = 0.35,
  }) {
    return Align(
      alignment: alignment,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}
