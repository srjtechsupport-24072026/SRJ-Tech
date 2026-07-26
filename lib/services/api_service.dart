import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/company.dart';
import '../models/contact_details.dart';
import '../models/service_item.dart';
import '../models/site_page.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Company> fetchCompany() async {
    final response = await _client.get(_uri('/company'));
    _ensureOk(response);
    return Company.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ContactDetails> fetchContactDetails() async {
    final response = await _client.get(_uri('/contact/details'));
    _ensureOk(response);
    return ContactDetails.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<SitePage> fetchPage(String slug) async {
    final response = await _client.get(_uri('/pages/$slug'));
    _ensureOk(response);
    return SitePage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ServiceItem>> fetchServices() async {
    final response = await _client.get(_uri('/services'));
    _ensureOk(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<String> submitContact({
    required String name,
    required String email,
    required String message,
    String phone = '',
    String companyName = '',
    String subject = '',
    String inquiryType = 'general',
    String source = 'website',
  }) async {
    final response = await _client.post(
      _uri('/contact'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'companyName': companyName,
        'subject': subject,
        'inquiryType': inquiryType,
        'message': message,
        'source': source,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['message'] as String? ?? 'Message sent.';
    }

    if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
      final first = (body['errors'] as List).first as Map<String, dynamic>;
      throw Exception(first['msg'] ?? 'Validation failed');
    }

    throw Exception(body['message'] ?? 'Failed to send message');
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed (${response.statusCode})');
    }
  }
}
