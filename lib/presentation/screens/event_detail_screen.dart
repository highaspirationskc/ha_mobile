import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero, // let image touch the edges (full-bleed)
      children: [
        // Full-bleed header image
        SizedBox(
          height: 240,
          width: double.infinity,
          child: _HeaderImage(src: event.image),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(event.dateTime),
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.place_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.location,
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(event.description, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String ordinal(int n) {
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

    final date = '${months[dt.month - 1]} ${ordinal(dt.day)}';
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$date, $h12:$m $ampm';
  }
}

class _HeaderImage extends StatelessWidget {
  final String src;
  const _HeaderImage({required this.src});

  @override
  Widget build(BuildContext context) {
    final isNetwork = src.startsWith('http');
    final img = isNetwork
        ? Image.network(src, fit: BoxFit.cover)
        : Image.asset(src, fit: BoxFit.cover);
    return img;
  }
}
