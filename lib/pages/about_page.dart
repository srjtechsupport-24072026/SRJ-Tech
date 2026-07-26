import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/site_page.dart';
import '../services/api_service.dart';
import '../widgets/effects/glass.dart';
import '../widgets/effects/parallax.dart';
import '../widgets/layout.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, required this.api});

  final ApiService api;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Future<SitePage> _future = widget.api.fetchPage('about');

  @override
  Widget build(BuildContext context) {
    return AsyncBody<SitePage>(
      future: _future,
      builder: (context, page) {
        final width = MediaQuery.sizeOf(context).width;

        return MaxWidth(
          child: Padding(
            padding: EdgeInsets.only(
              top: width >= 900 ? 72 : 48,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('About'),
                const SizedBox(height: 14),
                Text(
                  page.title,
                  style: GoogleFonts.syne(
                    fontSize: width >= 800 ? 52 : 36,
                    fontWeight: FontWeight.w700,
                    color: SrjColors.paper,
                    height: 1.05,
                    letterSpacing: -1.2,
                  ),
                ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    page.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                        ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 450.ms),
                const SizedBox(height: 48),
                const SoftDivider(),
                const SizedBox(height: 40),
                for (var i = 0; i < page.sections.length; i++) ...[
                  ParallaxLayer(
                    factor: 0.03 + (i * 0.015),
                    child: GlassPanel(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      opacity: 0.08,
                      child: _AboutSection(
                        section: page.sections[i],
                        index: i,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (120 * i).ms, duration: 450.ms)
                      .slideY(begin: 0.08, end: 0),
                  if (i < page.sections.length - 1) const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.section, required this.index});

  final PageSection section;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (index + 1).toString().padLeft(2, '0'),
          style: GoogleFonts.syne(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SrjColors.accent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.heading,
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: SrjColors.paper,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                section.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
