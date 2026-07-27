class TestimonialItem {
  const TestimonialItem({
    required this.quote,
    required this.authorName,
    this.authorRole = '',
    this.companyName = '',
    this.rating = 5,
    this.avatarUrl = '',
    this.order = 0,
    this.featured = true,
  });

  final String quote;
  final String authorName;
  final String authorRole;
  final String companyName;
  final int rating;
  final String avatarUrl;
  final int order;
  final bool featured;

  factory TestimonialItem.fromJson(Map<String, dynamic> json) {
    return TestimonialItem(
      quote: json['quote'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorRole: json['authorRole'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      featured: json['featured'] as bool? ?? true,
    );
  }
}
