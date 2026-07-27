import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/theme/app_theme.dart';
import '../models/company.dart';
import '../models/project_item.dart';
import '../models/service_item.dart';
import '../models/site_page.dart';
import '../models/testimonial_item.dart';
import '../services/api_service.dart';
import '../widgets/brand_logo.dart';
import '../widgets/effects/glass.dart';
import '../widgets/layout.dart';
import '../widgets/project_card.dart';
import '../widgets/testimonial_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api});

  final ApiService api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomeData> _future = _load();

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      widget.api.fetchCompany(),
      widget.api.fetchPage('home'),
      widget.api.fetchServices(),
      widget.api.fetchProjects(featuredOnly: true),
      widget.api.fetchTestimonials(featuredOnly: true),
    ]);
    return _HomeData(
      company: results[0] as Company,
      page: results[1] as SitePage,
      services: results[2] as List<ServiceItem>,
      projects: results[3] as List<ProjectItem>,
      testimonials: results[4] as List<TestimonialItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_HomeData>(
      future: _future,
      builder: (context, data) {
        final width = MediaQuery.sizeOf(context).width;
        final heroTitleSize = width >= 900 ? 58.0 : (width >= 600 ? 46.0 : 36.0);
        final desktop = width >= 900;

        return Column(
          children: [
            MaxWidth(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  desktop ? 64 : 40,
                  0,
                  desktop ? 88 : 56,
                ),
                child: desktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 11,
                            child: _HeroCopy(
                              tagline: data.company.tagline,
                              description: data.company.description,
                              titleSize: heroTitleSize,
                            ),
                          ),
                          const SizedBox(width: 36),
                          Expanded(
                            flex: 9,
                            child: Center(
                              child: _HeroLogo(
                                size: width >= 1200 ? 360 : 300,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _HeroLogo(size: width >= 600 ? 240 : 200),
                          const SizedBox(height: 28),
                          _HeroCopy(
                            tagline: data.company.tagline,
                            description: data.company.description,
                            titleSize: heroTitleSize,
                          ),
                        ],
                      ),
              ),
            ),
            MaxWidth(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Reveal(
                      keyName: 'home-capabilities-label',
                      child: SectionLabel('Capabilities'),
                    ),
                    const SizedBox(height: 14),
                    _Reveal(
                      keyName: 'home-capabilities-title',
                      delay: 80.ms,
                      child: Text(
                        'What we build',
                        style: GoogleFonts.syne(
                          fontSize: width >= 800 ? 42 : 32,
                          fontWeight: FontWeight.w700,
                          color: SrjColors.paper,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Reveal(
                      keyName: 'home-capabilities-body',
                      delay: 140.ms,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Text(
                          data.page.sections.isNotEmpty
                              ? data.page.sections.first.body
                              : 'Modern software products designed for clarity and growth.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 900
                            ? 2
                            : (constraints.maxWidth >= 560 ? 2 : 1);
                        final services = data.services.take(4).toList();
                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            for (var i = 0; i < services.length; i++)
                              SizedBox(
                                width: cols == 1
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth - 20) / 2,
                                child: _Reveal(
                                  keyName: 'home-service-$i',
                                  delay: (70 * (i % 2)).ms,
                                  slideY: 0.12,
                                  child: _ServicePreview(service: services[i]),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (data.page.sections.length > 1) ...[
                      const SizedBox(height: 72),
                      const _Reveal(
                        keyName: 'home-divider',
                        child: SoftDivider(),
                      ),
                      const SizedBox(height: 56),
                      _Reveal(
                        keyName: 'home-section2-title',
                        child: Text(
                          data.page.sections[1].heading,
                          style: GoogleFonts.syne(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: SrjColors.paper,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Reveal(
                        keyName: 'home-section2-body',
                        delay: 100.ms,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Text(
                            data.page.sections[1].body,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                    if (data.projects.isNotEmpty) ...[
                      const SizedBox(height: 80),
                      const _Reveal(
                        keyName: 'home-projects-label',
                        child: SectionLabel('Projects'),
                      ),
                      const SizedBox(height: 14),
                      _Reveal(
                        keyName: 'home-projects-title',
                        delay: 60.ms,
                        child: Text(
                          'Selected work',
                          style: GoogleFonts.syne(
                            fontSize: width >= 800 ? 42 : 32,
                            fontWeight: FontWeight.w700,
                            color: SrjColors.paper,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Reveal(
                        keyName: 'home-projects-body',
                        delay: 100.ms,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Text(
                            'A few engagements that show how we design, build, and ship with partners.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth >= 900
                              ? 2
                              : (constraints.maxWidth >= 560 ? 2 : 1);
                          final projects = data.projects.take(4).toList();
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (var i = 0; i < projects.length; i++)
                                SizedBox(
                                  width: cols == 1
                                      ? constraints.maxWidth
                                      : (constraints.maxWidth - 20) / 2,
                                  child: _Reveal(
                                    keyName: 'home-project-$i',
                                    delay: (70 * (i % 2)).ms,
                                    slideY: 0.12,
                                    child: ProjectCard(project: projects[i]),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      _Reveal(
                        keyName: 'home-projects-cta',
                        child: OutlinedButton(
                          onPressed: () => context.go('/projects'),
                          child: const Text('View all projects'),
                        ),
                      ),
                    ],
                    if (data.testimonials.isNotEmpty) ...[
                      const SizedBox(height: 80),
                      const _Reveal(
                        keyName: 'home-testimonials-label',
                        child: SectionLabel('Testimonials'),
                      ),
                      const SizedBox(height: 14),
                      _Reveal(
                        keyName: 'home-testimonials-title',
                        delay: 60.ms,
                        child: Text(
                          'Trusted by partners',
                          style: GoogleFonts.syne(
                            fontSize: width >= 800 ? 42 : 32,
                            fontWeight: FontWeight.w700,
                            color: SrjColors.paper,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Reveal(
                        keyName: 'home-testimonials-body',
                        delay: 100.ms,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Text(
                            'What clients say about working with SRJ Tech.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth >= 980
                              ? 3
                              : (constraints.maxWidth >= 640 ? 2 : 1);
                          final items = data.testimonials.take(3).toList();
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              for (var i = 0; i < items.length; i++)
                                SizedBox(
                                  width: cols == 1
                                      ? constraints.maxWidth
                                      : (constraints.maxWidth -
                                              (20 * (cols - 1))) /
                                          cols,
                                  child: _Reveal(
                                    keyName: 'home-testimonial-$i',
                                    delay: (80 * (i % cols)).ms,
                                    slideY: 0.12,
                                    child: TestimonialCard(
                                      testimonial: items[i],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 64),
                    _Reveal(
                      keyName: 'home-cta',
                      slideY: 0.14,
                      child: _CtaPanel(company: data.company),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.company,
    required this.page,
    required this.services,
    required this.projects,
    required this.testimonials,
  });

  final Company company;
  final SitePage page;
  final List<ServiceItem> services;
  final List<ProjectItem> projects;
  final List<TestimonialItem> testimonials;
}

/// Plays a fade + slide once the widget enters the viewport.
class _Reveal extends StatefulWidget {
  const _Reveal({
    required this.keyName,
    required this.child,
    this.delay = Duration.zero,
    this.slideY = 0.1,
  });

  final String keyName;
  final Widget child;
  final Duration delay;
  final double slideY;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.keyName),
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > 0.12) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : Offset(0, widget.slideY),
          duration: Duration(milliseconds: 560 + widget.delay.inMilliseconds),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.tagline,
    required this.description,
    required this.titleSize,
  });

  final String tagline;
  final String description;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final words = tagline.split(RegExp(r'\s+'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            for (var i = 0; i < words.length; i++)
              Padding(
                padding: EdgeInsets.only(right: i == words.length - 1 ? 0 : 12),
                child: Text(
                  words[i],
                  style: GoogleFonts.syne(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    height: 1.02,
                    letterSpacing: -1.8,
                    color: SrjColors.paper,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: (90 + i * 90).ms,
                      duration: 650.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.35,
                      end: 0,
                      delay: (90 + i * 90).ms,
                      duration: 700.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .blur(
                      begin: const Offset(0, 8),
                      end: Offset.zero,
                      delay: (90 + i * 90).ms,
                      duration: 550.ms,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        GlassPanel(
          borderRadius: 18,
          padding: const EdgeInsets.all(20),
          opacity: 0.07,
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  color: SrjColors.mist,
                ),
          ),
        )
            .animate()
            .fadeIn(delay: 380.ms, duration: 650.ms)
            .slideY(begin: 0.12, end: 0, delay: 380.ms, duration: 650.ms)
            .scale(
              begin: const Offset(0.97, 0.97),
              end: const Offset(1, 1),
              delay: 380.ms,
              duration: 650.ms,
              curve: Curves.easeOutCubic,
            ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/contact'),
              child: const Text('Start a project'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/services'),
              child: const Text('Explore services'),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 520.ms, duration: 550.ms)
            .slideY(begin: 0.18, end: 0, delay: 520.ms, duration: 550.ms),
      ],
    );
  }
}

class _CtaPanel extends StatelessWidget {
  const _CtaPanel({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 36,
      ),
      opacity: 0.11,
      blur: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to build with SRJ Tech?',
            style: GoogleFonts.syne(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: SrjColors.paper,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tell us about your product idea and we will help shape the first milestones.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            company.email,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SrjColors.accent,
                ),
          ),
          if (company.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              company.phone,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: SrjColors.lime,
                  ),
            ),
          ],
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => context.go('/contact'),
                child: const Text('Contact us'),
              ),
              OutlinedButton(
                onPressed: () => context.go('/contact'),
                child: const Text('View contact details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServicePreview extends StatefulWidget {
  const _ServicePreview({required this.service});

  final ServiceItem service;

  @override
  State<_ServicePreview> createState() => _ServicePreviewState();
}

class _ServicePreviewState extends State<_ServicePreview> {
  bool _hover = false;

  IconData get _icon {
    switch (widget.service.icon) {
      case 'phone':
        return Icons.phone_iphone_rounded;
      case 'api':
        return Icons.hub_outlined;
      case 'consult':
        return Icons.lightbulb_outline_rounded;
      case 'web':
      default:
        return Icons.language_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.025 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          child: GlassPanel(
            borderRadius: 20,
            padding: const EdgeInsets.all(24),
            opacity: _hover ? 0.14 : 0.09,
            borderOpacity: _hover ? 0.28 : 0.16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SrjColors.accent.withOpacity(_hover ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: SrjColors.accent, size: 24),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.service.title,
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SrjColors.paper,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.service.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  SrjColors.accent.withOpacity(0.26),
                  SrjColors.lime.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.06, 1.06),
                duration: 3200.ms,
                curve: Curves.easeInOut,
              )
              .fade(
                begin: 0.7,
                end: 1,
                duration: 3200.ms,
                curve: Curves.easeInOut,
              ),
          GlassPanel(
            borderRadius: size * 0.12,
            padding: EdgeInsets.all(size * 0.06),
            blur: 22,
            opacity: 0.08,
            child: BrandLogo(height: size * 0.78),
          )
              .animate()
              .fadeIn(duration: 700.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(0.86, 0.86),
                end: const Offset(1, 1),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -6,
                end: 6,
                duration: 2800.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}
