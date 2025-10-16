import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _EventImage(src: event.image),
            ),

            // Name / title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Text(
                event.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date/Time + Location row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    flex: 1,
                    child: Text(
                      _formatDateTime(event.dateTime),
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.place_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    flex: 1,
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
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
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

class _EventImage extends StatelessWidget {
  final String src;
  const _EventImage({required this.src});

  @override
  Widget build(BuildContext context) {
    // Supports either network or asset paths
    final isNetwork = src.startsWith('http');
    final borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    );

    final img = isNetwork
        ? Image.network(src, fit: BoxFit.cover)
        : Image.asset(src, fit: BoxFit.cover);

    return ClipRRect(borderRadius: borderRadius, child: img);
  }
}
