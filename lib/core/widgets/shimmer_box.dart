import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A pulsing placeholder block for skeleton loading states — shared across
/// every screen that needs "never show a blank screen" per UI_GUIDELINES.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.color,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.surfaceVariant;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.5 + (_controller.value * 0.5);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
