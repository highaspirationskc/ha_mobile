// lib/presentation/widgets/card_event.dart
import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../business/user/entities/user.dart';
import 'avatar_mini.dart';
import 'button_round_small.dart';
import '../../core/utils/date_formatters.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onRegister; // NEW

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: cs.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      formatCardDateTime(event.dateTime), // "Oct 25th, 5:00 PM"
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.place, size: 18, color: cs.primary),
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

            // Attending + Register row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  // LEFT: avatars + label (hug content)
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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

                  // RIGHT: register button
                  ButtonRoundSmall(
                    label: 'Register',
                    // onPressed: onRegister,
                    onPressed: () => print('Register'),
                    tonal: false, // primary by default
                    minHeight: 32,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

// Overlapped avatars width is tight so the label can sit close
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

    const step = faceSize + overlap; // effective spacing

    final facesWidth = visible.isEmpty
        ? 0.0
        : faceSize + (visible.length - 1) * step;
    final extraWidth = extra > 0 ? step : 0.0;
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
              child: AvatarMini(
                firstName: visible[i].firstName,
                lastName: visible[i].lastName,
                image: visible[i].image,
                size: faceSize,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * step,
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
        color: cs.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ), // match avatar border
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: cs.surface,
        ),
      ),
    );
  }
}
