import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.topChipLabel,
    required this.topChipValue,
    required this.bottomChipLabel,
    required this.bottomChipValue,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String topChipLabel;
  final String topChipValue;
  final String bottomChipLabel;
  final String bottomChipValue;
}

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.step});

  final OnboardingSlideData step;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return Stack(
          alignment: Alignment.center,
          children: [
            _FloatingElement(
              child: Container(
                width: size * 0.56,
                height: size * 0.56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: step.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: step.gradient.last.withValues(alpha: 0.45),
                      blurRadius: 46,
                      offset: const Offset(0, 22),
                    ),
                  ],
                ),
                child: Icon(step.icon, color: Colors.white, size: size * 0.2),
              ),
            ),
            Positioned(
              top: size * 0.02,
              left: 0,
              child: _FloatingElement(
                phase: 1.4,
                amplitude: 8,
                child: _GlassChip(
                  label: step.topChipLabel,
                  value: step.topChipValue,
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.04,
              right: 0,
              child: _FloatingElement(
                phase: 3.4,
                amplitude: 10,
                child: _GlassChip(
                  label: step.bottomChipLabel,
                  value: step.bottomChipValue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingElement extends StatefulWidget {
  const _FloatingElement({
    required this.child,
    this.amplitude = 10,
    this.phase = 0,
  });

  final Widget child;
  final double amplitude;
  final double phase;

  @override
  State<_FloatingElement> createState() => _FloatingElementState();
}

class _FloatingElementState extends State<_FloatingElement>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy =
            math.sin(_controller.value * 2 * math.pi + widget.phase) *
            widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
