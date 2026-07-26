class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.summary,
    required this.description,
    required this.icon,
    this.order = 0,
    this.featured = true,
  });

  final String title;
  final String summary;
  final String description;
  final String icon;
  final int order;
  final bool featured;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'code',
      order: json['order'] as int? ?? 0,
      featured: json['featured'] as bool? ?? true,
    );
  }
}
