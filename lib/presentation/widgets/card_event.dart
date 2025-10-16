// lib/presentation/widgets/card_event.dart
import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../business/user/entities/user.dart';
import 'avatar_mini.dart';

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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _EventImage(src: event.image),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4), // trimmed
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6), // trimmed
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
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

            // Attending row (avatars first, label trailing)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10), // trimmed
              child: Row(
                children: [
                  if (event.attendeeCount > 0) ...[
                    _AttendeesRow(users: event.attendees),
                    const SizedBox(width: 4),
                    Text(
                      'Attending',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ] else
                    Text(
                      'Be the first to register',
                      style: textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
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

class _EventImage extends StatelessWidget {
  final String src;
  const _EventImage({required this.src});

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
      child: Icon(Icons.image, color: cs.onSurfaceVariant),
    );
  }
}

class _AttendeesRow extends StatelessWidget {
  final List<User> users;
  const _AttendeesRow({required this.users});

  @override
  Widget build(BuildContext context) {
    const faceSize = 26.0;
    const overlap = -8.0; // negative = overlap
    const maxFaces = 3;

    final visible = users.take(maxFaces).toList();
    final extra = users.length - visible.length;

    // Effective step between faces accounting for overlap
    const step = faceSize + overlap; // 18.0 with values above

    // Compute total width of the overlapped cluster
    final facesWidth = visible.isEmpty
        ? 0.0
        : faceSize + (visible.length - 1) * step;

    final extraWidth = extra > 0
        ? step
        : 0.0; // "+N" bubble sits like another face

    final totalWidth = facesWidth + extraWidth;

    return SizedBox(
      width: totalWidth,
      height: faceSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * step,
              top: 0,
              child: AvatarMini(
                firstName: visible[i].firstName,
                lastName: visible[i].lastName,
                image: visible[i].image, // '' => initials fallback
                size: faceSize,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * step,
              top: 0,
              child: _ExtraCountCircle(count: extra, size: faceSize),
            ),
        ],
      ),
    );
  }
}

class _ExtraCountCircle extends StatelessWidget {
  final int count;
  final double size;
  const _ExtraCountCircle({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
