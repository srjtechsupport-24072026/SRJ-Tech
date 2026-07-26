import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SiteBreakpoints {
  static const double tablet = 800;
  static const double desktop = 1100;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= SiteBreakpoints.desktop;

bool isTablet(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= SiteBreakpoints.tablet && width < SiteBreakpoints.desktop;
}

class MaxWidth extends StatelessWidget {
  const MaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: SrjColors.accent,
            letterSpacing: 2.4,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
    );
  }
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: SrjColors.line.withOpacity(0.7),
    );
  }
}

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.future,
    required this.builder,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                Text(
                  'Unable to load content right now.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure the Node.js API is running and MongoDB is seeded.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return builder(context, snapshot.data as T);
      },
    );
  }
}
