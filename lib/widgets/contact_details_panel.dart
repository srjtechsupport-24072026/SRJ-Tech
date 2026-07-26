import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../models/contact_details.dart';
import 'effects/glass.dart';

class ContactDetailsPanel extends StatelessWidget {
  const ContactDetailsPanel({
    super.key,
    required this.details,
    this.title = 'Contact details',
    this.subtitle,
  });

  final ContactDetails details;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 22,
      padding: const EdgeInsets.all(28),
      opacity: 0.10,
      blur: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.syne(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: SrjColors.paper,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          for (var i = 0; i < details.channels.length; i++) ...[
            _ChannelTile(channel: details.channels[i]),
            if (i < details.channels.length - 1) const SizedBox(height: 12),
          ],
          if (details.businessHours.isNotEmpty ||
              details.responseTime.isNotEmpty ||
              details.locationLabel.isNotEmpty) ...[
            const SizedBox(height: 24),
            Divider(color: SrjColors.line.withOpacity(0.8), height: 1),
            const SizedBox(height: 20),
            if (details.businessHours.isNotEmpty)
              _MetaRow(
                icon: Icons.schedule_rounded,
                label: 'Business hours',
                value: details.businessHours,
              ),
            if (details.responseTime.isNotEmpty) ...[
              const SizedBox(height: 14),
              _MetaRow(
                icon: Icons.bolt_rounded,
                label: 'Response time',
                value: details.responseTime,
                accent: SrjColors.lime,
              ),
            ],
            if (details.locationLabel.isNotEmpty) ...[
              const SizedBox(height: 14),
              _MetaRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: details.locationLabel,
              ),
            ],
          ],
          if (details.supportNote.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: SrjColors.accent.withOpacity(0.08),
                border: Border.all(color: SrjColors.accent.withOpacity(0.2)),
              ),
              child: Text(
                details.supportNote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SrjColors.paper,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChannelTile extends StatefulWidget {
  const _ChannelTile({required this.channel});

  final ContactChannel channel;

  @override
  State<_ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<_ChannelTile> {
  bool _hover = false;

  IconData get _icon {
    switch (widget.channel.id) {
      case 'phone':
        return Icons.call_rounded;
      case 'whatsapp':
        return Icons.chat_bubble_outline_rounded;
      case 'email':
      default:
        return Icons.mail_outline_rounded;
    }
  }

  Color get _tint {
    switch (widget.channel.id) {
      case 'whatsapp':
        return SrjColors.lime;
      case 'phone':
        return SrjColors.glow;
      default:
        return SrjColors.accent;
    }
  }

  Future<void> _open() async {
    final uri = Uri.parse(widget.channel.href);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${widget.channel.label}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hover ? _tint.withOpacity(0.55) : SrjColors.line,
          ),
          color: _hover ? _tint.withOpacity(0.08) : SrjColors.inkSoft.withOpacity(0.45),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _open,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _tint.withOpacity(0.15),
                    ),
                    child: Icon(_icon, color: _tint, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.channel.label.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _tint,
                                letterSpacing: 1.4,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.channel.value,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: SrjColors.paper,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.channel.hint,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SrjColors.mist,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_outward_rounded, color: _tint, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = SrjColors.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent,
                      letterSpacing: 1.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SrjColors.paper,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
