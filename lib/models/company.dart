class Company {
  const Company({
    required this.name,
    required this.tagline,
    required this.description,
    required this.email,
    this.phone = '',
    this.whatsapp = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.businessHours = '',
    this.responseTime = '',
    this.supportNote = '',
    this.social = const {},
  });

  final String name;
  final String tagline;
  final String description;
  final String email;
  final String phone;
  final String whatsapp;
  final String address;
  final String city;
  final String country;
  final String businessHours;
  final String responseTime;
  final String supportNote;
  final Map<String, String> social;

  factory Company.fromJson(Map<String, dynamic> json) {
    final socialRaw = json['social'];
    final social = <String, String>{};
    if (socialRaw is Map) {
      socialRaw.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          social[key.toString()] = value.toString();
        }
      });
    }

    return Company(
      name: json['name'] as String? ?? 'SRJ Tech',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      businessHours: json['businessHours'] as String? ?? '',
      responseTime: json['responseTime'] as String? ?? '',
      supportNote: json['supportNote'] as String? ?? '',
      social: social,
    );
  }
}
