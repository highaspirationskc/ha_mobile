import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../widgets/avatar_mini.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero, // full-bleed image
      children: [
        // --- Header image ---
        SizedBox(
          height: 240,
          width: double.infinity,
          child: _HeaderImage(src: event.image),
        ),

        // --- Content ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                event.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Date / time block
              _InfoBlock(
                icon: Icons.calendar_today_outlined,
                title: _formatLongDate(event.dateTime),
                subtitle: _formatTime(event.dateTime),
              ),
              const _SectionDivider(),

              // Location block
              _InfoBlock(
                icon: Icons.place_outlined,
                title: event.location,
                subtitle: null, // add address line here if you have one
              ),
              const _SectionDivider(),

              // About / Description
              Text(
                'About',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(event.description, style: textTheme.bodyLarge),
              const _SectionDivider(),

              // Attending
              Row(
                children: [
                  Text(
                    'Attending (${event.attendees.length})',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AttendeesGrid(
                // show all attendees in a tidy wrap
                avatars: event.attendees
                    .map(
                      (u) => AvatarMini(
                        firstName: u.firstName,
                        lastName: u.lastName,
                        image: u.image, // '' => initials fallback
                        size: 40,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----- Formatters -----
  String _formatLongDate(DateTime dt) {
    const w = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const m = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    String ord(int n) {
      if (n >= 11 && n <= 13) return '${n}th';
      switch (n % 10) {
        case 1:
          return '${n}st';
        case 2:
          return '${n}nd';
        case 3:
          return '${n}rd';
        default:
          return '${n}th';
      }
    }

    return '${w[dt.weekday % 7]}, ${m[dt.month - 1]} ${ord(dt.day)}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    // If you later store an end time, render "$start – $end TZ" here
    return '$h:$min $ap';
  }
}

class _HeaderImage extends StatelessWidget {
  final String src;
  const _HeaderImage({required this.src});

  @override
  Widget build(BuildContext context) {
    final isNetwork = src.startsWith('http');
    final img = (src.trim().isEmpty)
        ? _placeholder(context)
        : isNetwork
        ? Image.network(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(context),
          )
        : Image.asset(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(context),
          );
    return img;
  }

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(Icons.image, color: cs.primary),
    );
  }
}

// A labeled info row with an icon, bold title, and optional subtitle on next line.
class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _InfoBlock({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// A subtle divider to separate sections, matching M3 outlineVariant.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: cs.outlineVariant),
    );
  }
}

// Simple responsive wrap of avatars (rows like your mock)
class _AttendeesGrid extends StatelessWidget {
  final List<Widget> avatars;
  const _AttendeesGrid({required this.avatars});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: avatars);
  }
}
