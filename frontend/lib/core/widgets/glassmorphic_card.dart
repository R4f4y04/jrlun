import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable translucent card with optional purple glow border.
/// Used across all screens for the premium dark glassmorphic look.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool glowBorder;
  final Color? backgroundColor;
  final double borderRadius;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.glowBorder = false,
    this.backgroundColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (backgroundColor ?? const Color(0xFF1A1A2E)).withValues(alpha: 0.8),
            (backgroundColor ?? const Color(0xFF16162A)).withValues(alpha: 0.6),
          ],
        ),
        border: glowBorder
            ? Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                width: 1,
              )
            : Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
        boxShadow: glowBorder
            ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
