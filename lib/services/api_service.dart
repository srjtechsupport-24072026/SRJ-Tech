import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/company.dart';
import '../models/contact_details.dart';
import '../models/project_item.dart';
import '../models/service_item.dart';
import '../models/site_page.dart';
import '../models/testimonial_item.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Render free services sleep after idle time; first wake can take 30–60s.
  static const Duration requestTimeout = Duration(seconds: 55);
  static const int maxAttempts = 3;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<http.Response> _get(String path) => _send(
        () => _client.get(_uri(path)).timeout(requestTimeout),
      );

  Future<http.Response> _post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      _send(
        () => _client
            .post(_uri(path), headers: headers, body: body)
            .timeout(requestTimeout),
      );

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await request();
        // Retry transient gateway / cold-start failures from Render.
        if (response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504) {
          lastError = Exception('Request failed (${response.statusCode})');
          if (attempt < maxAttempts) {
            await Future<void>.delayed(Duration(seconds: attempt * 2));
            continue;
          }
        }
        return response;
      } on TimeoutException catch (error) {
        lastError = error;
        if (attempt >= maxAttempts) break;
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      } on http.ClientException catch (error) {
        lastError = error;
        if (attempt >= maxAttempts) break;
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception(
      'Unable to reach SRJ Tech API after $maxAttempts attempts. '
      'The server may be waking up — please refresh in a moment. '
      '($lastError)',
    );
  }

  Future<Company> fetchCompany() async {
    final response = await _get('/company');
    _ensureOk(response);
    return Company.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ContactDetails> fetchContactDetails() async {
    final response = await _get('/contact/details');
    _ensureOk(response);
    return ContactDetails.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<SitePage> fetchPage(String slug) async {
    final response = await _get('/pages/$slug');
    _ensureOk(response);
    return SitePage.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<ServiceItem>> fetchServices() async {
    final response = await _get('/services');
    _ensureOk(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<ProjectItem>> fetchProjects({bool featuredOnly = false}) async {
    final path =
        featuredOnly ? '/projects?featured=true' : '/projects';
    final response = await _get(path);
    _ensureOk(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => ProjectItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<ProjectItem> fetchProject(String slug) async {
    final response = await _get('/projects/$slug');
    _ensureOk(response);
    return ProjectItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<TestimonialItem>> fetchTestimonials({
    bool featuredOnly = false,
  }) async {
    final path =
        featuredOnly ? '/testimonials?featured=true' : '/testimonials';
    final response = await _get(path);
    _ensureOk(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => TestimonialItem.fromJson(e as Map<String, dynamic>))
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
    final response = await _post(
      '/contact',
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
