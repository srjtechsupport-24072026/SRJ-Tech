import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/service_item.dart';
import '../models/site_page.dart';
import '../services/api_service.dart';
import '../widgets/effects/glass.dart';
import '../widgets/layout.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key, required this.api});

  final ApiService api;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late final Future<_ServicesData> _future = _load();

  Future<_ServicesData> _load() async {
    final results = await Future.wait([
      widget.api.fetchPage('services'),
      widget.api.fetchServices(),
    ]);
    return _ServicesData(
      page: results[0] as SitePage,
      services: results[1] as List<ServiceItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_ServicesData>(
      future: _future,
      builder: (context, data) {
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
                const SectionLabel('Services'),
                const SizedBox(height: 14),
                Text(
                  data.page.title,
                  style: GoogleFonts.syne(
                    fontSize: width >= 800 ? 52 : 36,
                    fontWeight: FontWeight.w700,
                    color: SrjColors.paper,
                    letterSpacing: -1.2,
                  ),
                ).animate().fadeIn(duration: 450.ms),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    data.page.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                        ),
                  ),
                ),
                if (data.page.sections.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      data.page.sections.first.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                for (var i = 0; i < data.services.length; i++) ...[
                  GlassPanel(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 20,
                    ),
                    opacity: 0.09,
                    child: _ServiceRow(
                      service: data.services[i],
                      index: i,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (90 * i).ms, duration: 450.ms)
                      .slideY(begin: 0.06, end: 0),
                  if (i < data.services.length - 1) const SizedBox(height: 16),
                ],
                const SizedBox(height: 56),
                FilledButton(
                  onPressed: () => context.go('/contact'),
                  child: const Text('Discuss your project'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServicesData {
  const _ServicesData({required this.page, required this.services});

  final SitePage page;
  final List<ServiceItem> services;
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.service, required this.index});

  final ServiceItem service;
  final int index;

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
    final wide = MediaQuery.sizeOf(context).width >= 800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child:                     Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: GoogleFonts.syne(
                      color: SrjColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(_icon, color: SrjColors.accent, size: 28),
                const SizedBox(width: 20),
                Expanded(
                  flex: 4,
                  child: Text(
                    service.title,
                    style: GoogleFonts.syne(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: SrjColors.paper,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.summary,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: SrjColors.paper,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_icon, color: SrjColors.accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.title,
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: SrjColors.paper,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  service.summary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SrjColors.paper,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
    );
  }
}
