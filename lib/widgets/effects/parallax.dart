import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Provides the current page scroll offset to descendants.
class ScrollOffsetScope extends InheritedNotifier<ValueNotifier<double>> {
  const ScrollOffsetScope({
    super.key,
    required ValueNotifier<double> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static double of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ScrollOffsetScope>();
    return scope?.notifier?.value ?? 0;
  }
}

/// Moves [child] at a fraction of scroll speed for parallax depth.
class ParallaxLayer extends StatelessWidget {
  const ParallaxLayer({
    super.key,
    required this.child,
    this.factor = 0.25,
    this.horizontalFactor = 0,
  });

  /// Positive values move with scroll (slower when below 1).
  /// Negative values move opposite to scroll.
  final double factor;
  final double horizontalFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = ScrollOffsetScope.of(context);
    return Transform.translate(
      offset: Offset(offset * horizontalFactor, offset * factor),
      child: child,
    );
  }
}

/// Soft atmospheric orbs that drift with parallax behind page content.
class ParallaxAtmosphere extends StatelessWidget {
  const ParallaxAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return IgnorePointer(
      child: Stack(
        children: [
          ParallaxLayer(
            factor: -0.18,
            child: Align(
              alignment: const Alignment(0.85, -0.55),
              child: _Orb(
                diameter: size.width * 0.55,
                colors: [
                  SrjColors.accent.withOpacity(0.20),
                  SrjColors.lime.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ParallaxLayer(
            factor: -0.32,
            horizontalFactor: 0.04,
            child: Align(
              alignment: const Alignment(-1.05, 0.15),
              child: _Orb(
                diameter: size.width * 0.48,
                colors: [
                  SrjColors.lime.withOpacity(0.14),
                  SrjColors.accent.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ParallaxLayer(
            factor: -0.12,
            child: Align(
              alignment: const Alignment(0.2, 0.85),
              child: _Orb(
                diameter: size.width * 0.4,
                colors: [
                  SrjColors.glow.withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          ParallaxLayer(
            factor: 0.08,
            child: CustomPaint(
              size: Size(size.width, size.height * 1.6),
              painter: _ParallaxGridPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.diameter, required this.colors});

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _ParallaxGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SrjColors.line.withOpacity(0.16)
      ..strokeWidth = 1;

    const step = 64.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
