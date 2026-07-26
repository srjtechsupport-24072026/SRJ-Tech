import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/contact_details.dart';
import '../models/site_page.dart';
import '../services/api_service.dart';
import '../widgets/contact_details_panel.dart';
import '../widgets/contact_inquiry_form.dart';
import '../widgets/effects/glass.dart';
import '../widgets/layout.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key, required this.api});

  final ApiService api;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late final Future<_ContactData> _future = _load();

  Future<_ContactData> _load() async {
    final results = await Future.wait([
      widget.api.fetchContactDetails(),
      widget.api.fetchPage('contact'),
    ]);
    return _ContactData(
      details: results[0] as ContactDetails,
      page: results[1] as SitePage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBody<_ContactData>(
      future: _future,
      builder: (context, data) {
        final width = MediaQuery.sizeOf(context).width;
        final wide = width >= 920;
        final sectionBody = data.page.sections.isNotEmpty
            ? data.page.sections.first.body
            : data.details.supportNote;

        return MaxWidth(
          child: Padding(
            padding: EdgeInsets.only(
              top: width >= 900 ? 72 : 48,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Contact'),
                const SizedBox(height: 14),
                Text(
                  data.page.title,
                  style: GoogleFonts.syne(
                    fontSize: width >= 800 ? 52 : 36,
                    fontWeight: FontWeight.w700,
                    color: SrjColors.paper,
                    letterSpacing: -1.2,
                  ),
                ).animate().fadeIn(duration: 450.ms),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    data.page.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 19,
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: GlassPanel(
                              borderRadius: 22,
                              padding: const EdgeInsets.all(24),
                              opacity: 0.08,
                              child: ContactInquiryForm(
                                api: widget.api,
                                inquiryTypes: data.details.inquiryTypes,
                              ),
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 4,
                            child: ContactDetailsPanel(
                              details: data.details,
                              title: data.page.sections.isNotEmpty
                                  ? data.page.sections.first.heading
                                  : 'Contact details',
                              subtitle: sectionBody,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContactDetailsPanel(
                            details: data.details,
                            title: data.page.sections.isNotEmpty
                                ? data.page.sections.first.heading
                                : 'Contact details',
                            subtitle: sectionBody,
                          ),
                          const SizedBox(height: 24),
                          GlassPanel(
                            borderRadius: 22,
                            padding: const EdgeInsets.all(24),
                            opacity: 0.08,
                            child: ContactInquiryForm(
                              api: widget.api,
                              inquiryTypes: data.details.inquiryTypes,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContactData {
  const _ContactData({required this.details, required this.page});

  final ContactDetails details;
  final SitePage page;
}
