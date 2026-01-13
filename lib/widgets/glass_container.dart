import 'package:flutter/material.dart';
import 'dart:ui';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.color = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFFFFFFF),
    this.borderWidth = 1.5,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.opacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            border: Border.all(
              color: borderColor.withValues(alpha: opacity * 0.5),
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
