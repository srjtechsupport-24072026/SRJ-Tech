class ContactChannel {
  const ContactChannel({
    required this.id,
    required this.label,
    required this.value,
    required this.hint,
    required this.actionLabel,
    required this.href,
  });

  final String id;
  final String label;
  final String value;
  final String hint;
  final String actionLabel;
  final String href;

  factory ContactChannel.fromJson(Map<String, dynamic> json) {
    return ContactChannel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'Open',
      href: json['href'] as String? ?? '',
    );
  }
}

class InquiryTypeOption {
  const InquiryTypeOption({required this.id, required this.label});

  final String id;
  final String label;

  factory InquiryTypeOption.fromJson(Map<String, dynamic> json) {
    return InquiryTypeOption(
      id: json['id'] as String? ?? 'general',
      label: json['label'] as String? ?? 'General inquiry',
    );
  }
}

class ContactDetails {
  const ContactDetails({
    required this.companyName,
    required this.email,
    required this.phone,
    required this.whatsapp,
    required this.address,
    required this.city,
    required this.country,
    required this.businessHours,
    required this.responseTime,
    required this.supportNote,
    required this.channels,
    required this.inquiryTypes,
    this.social = const {},
  });

  final String companyName;
  final String email;
  final String phone;
  final String whatsapp;
  final String address;
  final String city;
  final String country;
  final String businessHours;
  final String responseTime;
  final String supportNote;
  final List<ContactChannel> channels;
  final List<InquiryTypeOption> inquiryTypes;
  final Map<String, String> social;

  String get locationLabel {
    final parts = [city, country, address]
        .where((part) => part.trim().isNotEmpty)
        .toSet()
        .toList();
    return parts.join(', ');
  }

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    final channelsRaw = json['channels'] as List<dynamic>? ?? [];
    final typesRaw = json['inquiryTypes'] as List<dynamic>? ?? [];
    final socialRaw = json['social'];
    final social = <String, String>{};
    if (socialRaw is Map) {
      socialRaw.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          social[key.toString()] = value.toString();
        }
      });
    }

    return ContactDetails(
      companyName: json['companyName'] as String? ?? 'SRJ Tech',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      whatsapp: json['whatsapp'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      businessHours: json['businessHours'] as String? ?? '',
      responseTime: json['responseTime'] as String? ?? '',
      supportNote: json['supportNote'] as String? ?? '',
      channels: channelsRaw
          .map((e) => ContactChannel.fromJson(e as Map<String, dynamic>))
          .toList(),
      inquiryTypes: typesRaw
          .map((e) => InquiryTypeOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      social: social,
    );
  }
}
