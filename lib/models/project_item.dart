class ProjectItem {
  const ProjectItem({
    required this.title,
    required this.slug,
    required this.summary,
    required this.description,
    this.client = '',
    this.industry = '',
    this.year = '',
    this.technologies = const [],
    this.highlights = const [],
    this.imageUrl = '',
    this.projectUrl = '',
    this.order = 0,
    this.featured = true,
  });

  final String title;
  final String slug;
  final String summary;
  final String description;
  final String client;
  final String industry;
  final String year;
  final List<String> technologies;
  final List<String> highlights;
  final String imageUrl;
  final String projectUrl;
  final int order;
  final bool featured;

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String? ?? '',
      client: json['client'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      year: json['year'] as String? ?? '',
      technologies: (json['technologies'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      highlights: (json['highlights'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String? ?? '',
      projectUrl: json['projectUrl'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      featured: json['featured'] as bool? ?? true,
    );
  }
}
