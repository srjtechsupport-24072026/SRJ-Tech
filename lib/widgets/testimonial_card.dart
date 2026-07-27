import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/testimonial_item.dart';
import 'effects/glass.dart';

class TestimonialCard extends StatefulWidget {
  const TestimonialCard({super.key, required this.testimonial});

  final TestimonialItem testimonial;

  @override
  State<TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<TestimonialCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.testimonial;
    final initials = item.authorName.isNotEmpty
        ? item.authorName
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : 'SR';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: GlassPanel(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          opacity: _hover ? 0.13 : 0.09,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < item.rating.clamp(1, 5); i++)
                    const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: SrjColors.lime,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '"${item.quote}"',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  height: 1.55,
                  color: SrjColors.paper,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: SrjColors.accent.withOpacity(0.2),
                    child: Text(
                      initials,
                      style: GoogleFonts.syne(
                        color: SrjColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.authorName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: SrjColors.paper,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (item.authorRole.isNotEmpty) item.authorRole,
                            if (item.companyName.isNotEmpty) item.companyName,
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SrjColors.mist,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
