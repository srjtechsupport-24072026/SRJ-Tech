import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../models/project_item.dart';
import 'effects/glass.dart';

class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.expanded = false,
  });

  final ProjectItem project;
  final bool expanded;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.015 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: GlassPanel(
          borderRadius: 22,
          padding: const EdgeInsets.all(24),
          opacity: _hover ? 0.13 : 0.09,
          borderOpacity: _hover ? 0.26 : 0.16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (project.industry.isNotEmpty)
                    _MetaChip(label: project.industry),
                  if (project.year.isNotEmpty) _MetaChip(label: project.year),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                project.title,
                style: GoogleFonts.syne(
                  fontSize: widget.expanded ? 28 : 22,
                  fontWeight: FontWeight.w700,
                  color: SrjColors.paper,
                  height: 1.15,
                ),
              ),
              if (project.client.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.client,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SrjColors.accent,
                        letterSpacing: 0.4,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                widget.expanded ? project.description : project.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SrjColors.mist,
                      height: 1.5,
                    ),
              ),
              if (project.technologies.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tech in project.technologies)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          tech,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: SrjColors.paper,
                              ),
                        ),
                      ),
                  ],
                ),
              ],
              if (widget.expanded && project.highlights.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (final highlight in project.highlights) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: SrjColors.lime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          highlight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (project.projectUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => launchUrl(Uri.parse(project.projectUrl)),
                  child: const Text('View project'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: SrjColors.lime,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
