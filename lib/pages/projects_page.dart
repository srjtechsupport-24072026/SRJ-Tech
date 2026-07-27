import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/project_item.dart';
import '../models/site_page.dart';
import '../services/api_service.dart';
import '../widgets/layout.dart';
import '../widgets/project_card.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, required this.api});

  final ApiService api;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final Future<_ProjectsData> _future = _load();

  Future<_ProjectsData> _load() async {
    final results = await Future.wait([
      widget.api.fetchPage('projects'),
      widget.api.fetchProjects(),
    ]);
    return _ProjectsData(
      page: results[0] as SitePage,
      projects: results[1] as List<ProjectItem>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_ProjectsData>(
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
                const SectionLabel('Projects'),
                const SizedBox(height: 14),
                Text(
                  data.page.title,
                  style: GoogleFonts.syne(
                    fontSize: width >= 800 ? 52 : 36,
                    fontWeight: FontWeight.w700,
                    color: SrjColors.paper,
                    letterSpacing: -1.2,
                  ),
                ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    data.page.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                        ),
                  ),
                ).animate().fadeIn(delay: 80.ms, duration: 450.ms),
                if (data.page.sections.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      data.page.sections.first.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                for (var i = 0; i < data.projects.length; i++) ...[
                  ProjectCard(
                    project: data.projects[i],
                    expanded: true,
                  )
                      .animate()
                      .fadeIn(delay: (90 * i).ms, duration: 450.ms)
                      .slideY(begin: 0.08, end: 0),
                  if (i < data.projects.length - 1) const SizedBox(height: 20),
                ],
                const SizedBox(height: 56),
                FilledButton(
                  onPressed: () => context.go('/contact'),
                  child: const Text('Start a similar project'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectsData {
  const _ProjectsData({required this.page, required this.projects});

  final SitePage page;
  final List<ProjectItem> projects;
}
