import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme.dart';
import '../models/contact_details.dart';
import '../services/api_service.dart';

class ContactInquiryForm extends StatefulWidget {
  const ContactInquiryForm({
    super.key,
    required this.api,
    required this.inquiryTypes,
  });

  final ApiService api;
  final List<InquiryTypeOption> inquiryTypes;

  @override
  State<ContactInquiryForm> createState() => _ContactInquiryFormState();
}

class _ContactInquiryFormState extends State<ContactInquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _inquiryType = 'general';
  bool _submitting = false;
  String? _successMessage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.inquiryTypes.isNotEmpty) {
      _inquiryType = widget.inquiryTypes.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _successMessage = null;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final message = await widget.api.submitContact(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        companyName: _companyController.text.trim(),
        subject: _subjectController.text.trim(),
        inquiryType: _inquiryType,
        message: _messageController.text.trim(),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _companyController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _inquiryType =
            widget.inquiryTypes.isNotEmpty ? widget.inquiryTypes.first.id : 'general';
        _successMessage = message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = widget.inquiryTypes.isNotEmpty
        ? widget.inquiryTypes
        : const [
            InquiryTypeOption(id: 'general', label: 'General inquiry'),
            InquiryTypeOption(id: 'project', label: 'New project'),
            InquiryTypeOption(id: 'support', label: 'Support'),
            InquiryTypeOption(id: 'partnership', label: 'Partnership'),
          ];

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send a message',
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SrjColors.paper,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us about your idea, product, or support need.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in types)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _inquiryType == type.id,
                  onSelected: (_) => setState(() => _inquiryType = type.id),
                  selectedColor: SrjColors.accent.withOpacity(0.25),
                  backgroundColor: SrjColors.panel,
                  labelStyle: TextStyle(
                    color: _inquiryType == type.id ? SrjColors.paper : SrjColors.mist,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _inquiryType == type.id
                        ? SrjColors.accent
                        : SrjColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Your full name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@company.com',
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty || !email.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = constraints.maxWidth >= 520;
              final phoneField = TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: '+91 ...',
                ),
              );
              final companyField = TextFormField(
                controller: _companyController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Company (optional)',
                  hintText: 'Your company name',
                ),
              );

              if (!sideBySide) {
                return Column(
                  children: [
                    phoneField,
                    const SizedBox(height: 14),
                    companyField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: phoneField),
                  const SizedBox(width: 14),
                  Expanded(child: companyField),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _subjectController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Subject',
              hintText: 'Project inquiry',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Tell us about your idea, timeline, and goals',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().length < 10) {
                return 'Please share a bit more detail (10+ characters)';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SrjColors.paper,
                    ),
                  )
                : const Text('Send message'),
          ),
          if (_successMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SrjColors.lime.withOpacity(0.12),
                border: Border.all(color: SrjColors.lime.withOpacity(0.35)),
              ),
              child: Text(
                _successMessage!,
                style: const TextStyle(color: SrjColors.lime),
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF8A7A).withOpacity(0.12),
                border: Border.all(color: const Color(0xFFFF8A7A).withOpacity(0.4)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFFF8A7A)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
