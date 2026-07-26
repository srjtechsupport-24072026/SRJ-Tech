import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Frosted-glass surface using backdrop blur + translucent fill.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.blur = 18,
    this.opacity = 0.10,
    this.borderOpacity = 0.16,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
            ),
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(opacity + 0.04),
                    SrjColors.panel.withOpacity(opacity + 0.08),
                    Colors.white.withOpacity(opacity * 0.4),
                  ],
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Slim glass bar for sticky navigation.
class GlassBar extends StatelessWidget {
  const GlassBar({
    super.key,
    required this.child,
    this.height = 88,
    this.blur = 22,
  });

  final Widget child;
  final double height;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: SrjColors.ink.withOpacity(0.45),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.08),
                SrjColors.ink.withOpacity(0.35),
              ],
            ),
          ),
          child: SizedBox(height: height, child: child),
        ),
      ),
    );
  }
}
