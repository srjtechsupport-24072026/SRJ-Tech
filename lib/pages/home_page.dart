import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/company.dart';
import '../models/service_item.dart';
import '../models/site_page.dart';
import '../services/api_service.dart';
import '../widgets/brand_logo.dart';
import '../widgets/effects/glass.dart';
import '../widgets/effects/parallax.dart';
import '../widgets/layout.dart';

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
    ]);
    return _HomeData(
      company: results[0] as Company,
      page: results[1] as SitePage,
      services: results[2] as List<ServiceItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_HomeData>(
      future: _future,
      builder: (context, data) {
        final width = MediaQuery.sizeOf(context).width;
        final heroTitleSize = width >= 900 ? 72.0 : (width >= 600 ? 52.0 : 40.0);

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ParallaxLayer(
                    factor: -0.28,
                    child: Align(
                      alignment: width >= 900
                          ? Alignment.centerRight
                          : Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: width >= 900 ? 24 : 0,
                          top: width >= 900 ? 8 : 0,
                        ),
                        child: _HeroLogo(size: width >= 900 ? 420 : 260),
                      ),
                    ),
                  ),
                  MaxWidth(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        width >= 900 ? 72 : 280,
                        0,
                        width >= 900 ? 100 : 64,
                      ),
                      child: ParallaxLayer(
                        factor: 0.12,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width >= 900 ? 560 : 820,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.company.tagline,
                                style: GoogleFonts.syne(
                                  fontSize: heroTitleSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.02,
                                  letterSpacing: -1.8,
                                  color: SrjColors.paper,
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 80.ms, duration: 600.ms)
                                  .slideY(begin: 0.12, end: 0),
                              const SizedBox(height: 22),
                              GlassPanel(
                                borderRadius: 18,
                                padding: const EdgeInsets.all(20),
                                opacity: 0.07,
                                child: Text(
                                  data.company.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontSize: 18,
                                        color: SrjColors.mist,
                                      ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 160.ms, duration: 600.ms),
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
                                  .fadeIn(delay: 240.ms, duration: 500.ms)
                                  .slideY(begin: 0.1, end: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MaxWidth(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Capabilities'),
                    const SizedBox(height: 14),
                    Text(
                      'What we build',
                      style: GoogleFonts.syne(
                        fontSize: width >= 800 ? 42 : 32,
                        fontWeight: FontWeight.w700,
                        color: SrjColors.paper,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Text(
                        data.page.sections.isNotEmpty
                            ? data.page.sections.first.body
                            : 'Modern software products designed for clarity and growth.',
                        style: Theme.of(context).textTheme.bodyLarge,
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
                                child: ParallaxLayer(
                                  factor: 0.04 + (i % 2) * 0.03,
                                  child: _ServicePreview(service: services[i])
                                      .animate()
                                      .fadeIn(
                                        delay: (80 * i).ms,
                                        duration: 450.ms,
                                      )
                                      .slideY(begin: 0.08, end: 0),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (data.page.sections.length > 1) ...[
                      const SizedBox(height: 72),
                      const SoftDivider(),
                      const SizedBox(height: 56),
                      Text(
                        data.page.sections[1].heading,
                        style: GoogleFonts.syne(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: SrjColors.paper,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Text(
                          data.page.sections[1].body,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    const SizedBox(height: 64),
                    ParallaxLayer(
                      factor: 0.06,
                      child: GlassPanel(
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
                              data.company.email,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SrjColors.accent,
                                  ),
                            ),
                            if (data.company.phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                data.company.phone,
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
                      ),
                    ),
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
  });

  final Company company;
  final SitePage page;
  final List<ServiceItem> services;
}

class _ServicePreview extends StatelessWidget {
  const _ServicePreview({required this.service});

  final ServiceItem service;

  IconData get _icon {
    switch (service.icon) {
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
    return GlassPanel(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      opacity: 0.09,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: SrjColors.accent, size: 28),
          const SizedBox(height: 18),
          Text(
            service.title,
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SrjColors.paper,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            service.summary,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
          ),
          GlassPanel(
            borderRadius: size * 0.12,
            padding: EdgeInsets.all(size * 0.06),
            blur: 22,
            opacity: 0.08,
            child: BrandLogo(height: size * 0.78),
          ),
        ],
      ),
    );
  }
}
