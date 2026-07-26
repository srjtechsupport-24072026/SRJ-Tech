class PageSection {
  const PageSection({
    required this.heading,
    required this.body,
    this.order = 0,
  });

  final String heading;
  final String body;
  final int order;

  factory PageSection.fromJson(Map<String, dynamic> json) {
    return PageSection(
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class SitePage {
  const SitePage({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String slug;
  final String title;
  final String subtitle;
  final List<PageSection> sections;

  factory SitePage.fromJson(Map<String, dynamic> json) {
    final sectionsRaw = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsRaw
        .map((e) => PageSection.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return SitePage(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      sections: sections,
    );
  }
}
