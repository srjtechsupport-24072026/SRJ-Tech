import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../models/company.dart';
import 'brand_logo.dart';
import 'effects/glass.dart';
import 'effects/parallax.dart';
import 'layout.dart';

class SiteShell extends StatefulWidget {
  const SiteShell({
    super.key,
    required this.companyFuture,
    required this.currentPath,
    required this.child,
  });

  final Future<Company> companyFuture;
  final String currentPath;
  final Widget child;

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final _scrollController = ScrollController();
  final _scrollOffset = ValueNotifier<double>(0);

  static const _headerHeight = 88.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    _scrollOffset.value = _scrollController.offset;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Company>(
        future: widget.companyFuture,
        builder: (context, snapshot) {
          final company = snapshot.data ??
              const Company(
                name: 'SRJ Tech',
                tagline: 'Innovate • Solve • Elevate',
                description: '',
                email: 'srjtechsupport@gmail.com',
                phone: '+91 81379 67192',
              );

          return ScrollOffsetScope(
            notifier: _scrollOffset,
            child: Stack(
              children: [
                const Positioned.fill(child: ParallaxAtmosphere()),
                SelectionArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    clipBehavior: Clip.none,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: _headerHeight),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          width: double.infinity,
                          child: widget.child,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          width: double.infinity,
                          child: SiteFooter(company: company),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SiteHeader(
                    company: company,
                    currentPath: widget.currentPath,
                    scrolled: _scrollOffset,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.company,
    required this.currentPath,
    required this.scrolled,
  });

  final Company company;
  final String currentPath;
  final ValueNotifier<double> scrolled;

  static const _links = [
    ('/', 'Home'),
    ('/about', 'About'),
    ('/services', 'Services'),
    ('/projects', 'Projects'),
    ('/contact', 'Contact'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return ValueListenableBuilder<double>(
      valueListenable: scrolled,
      builder: (context, offset, _) {
        final elevated = offset > 12;

        return GlassBar(
          blur: elevated ? 28 : 18,
          child: MaxWidth(
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    child: BrandLogo(height: 64, style: BrandLogoStyle.full),
                  ),
                ),
                const Spacer(),
                if (wide)
                  Row(
                    children: [
                      for (final link in _links)
                        _NavLink(
                          label: link.$2,
                          selected: currentPath == link.$1,
                          onTap: () => context.go(link.$1),
                        ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => context.go('/contact'),
                        child: const Text('Start a project'),
                      ),
                    ],
                  )
                else
                  IconButton(
                    onPressed: () => _openMobileNav(context),
                    icon: const Icon(Icons.menu_rounded),
                    color: SrjColors.paper,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openMobileNav(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            borderRadius: 22,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final link in _links)
                    ListTile(
                      title: Text(
                        link.$2,
                        style: TextStyle(
                          color: currentPath == link.$1
                              ? SrjColors.accent
                              : SrjColors.paper,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.go(link.$1);
                      },
                    ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/contact');
                    },
                    child: const Text('Start a project'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: TextButton(
        onPressed: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: GoogleFonts.outfit(
            color: active ? SrjColors.paper : SrjColors.mist,
            fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 48, 0, 40),
      child: MaxWidth(
        child: GlassPanel(
          borderRadius: 28,
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
          opacity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLogo(height: 96, style: BrandLogoStyle.full),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  company.tagline,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 28,
                runSpacing: 12,
                children: [
                  _FooterMeta(
                    label: 'Email',
                    value: company.email,
                    onTap: () => launchUrl(Uri.parse('mailto:${company.email}')),
                  ),
                  if (company.phone.isNotEmpty)
                    _FooterMeta(
                      label: 'Phone',
                      value: company.phone,
                      onTap: () => launchUrl(
                        Uri.parse(
                          'tel:${company.phone.replaceAll(RegExp(r'\D'), '')}',
                        ),
                      ),
                    ),
                  if (company.businessHours.isNotEmpty)
                    _FooterMeta(
                      label: 'Hours',
                      value: company.businessHours,
                    ),
                  if (company.address.isNotEmpty)
                    _FooterMeta(label: 'Location', value: company.address),
                ],
              ),
              const SizedBox(height: 32),
              const SoftDivider(),
              const SizedBox(height: 20),
              Text(
                '© ${DateTime.now().year} ${company.name}. All rights reserved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterMeta extends StatelessWidget {
  const _FooterMeta({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SrjColors.accent,
                letterSpacing: 1.6,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SrjColors.paper,
                decoration: onTap != null ? TextDecoration.underline : null,
                decorationColor: SrjColors.mist,
              ),
        ),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}
