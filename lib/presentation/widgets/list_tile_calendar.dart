// lib/presentation/widgets/list_tile_calendar.dart
import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';

class ListTileCalendar extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool compact;
  final bool showChevron;

  const ListTileCalendar({
    super.key,
    required this.event,
    this.onTap,
    this.compact = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      dense: compact,
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      leading: compact
          ? const Icon(Icons.event)
          : _Thumb(src: event.imageUrl ?? ''),
      title: Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${_fmtDate(event.eventDate)} • ${_fmtTime(event.eventDate)} • ${event.location ?? 'TBD'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
      trailing: showChevron ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  String _fmtDate(DateTime dt) {
    const m = [
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
    return '${m[dt.month - 1]} ${dt.day}';
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$min $ap';
  }
}

/// Fixed-size thumbnail that gracefully falls back when image is missing/404.
class _Thumb extends StatelessWidget {
  final String src;
  const _Thumb({required this.src});

  @override
  Widget build(BuildContext context) {
    const double size = 56;
    final cs = Theme.of(context).colorScheme;

    // Empty or whitespace? show placeholder.
    if (src.trim().isEmpty) return _placeholder(size, cs);

    final isNetwork = src.startsWith('http');

    final image = isNetwork
        ? Image.network(
            src,
            width: size,
            height: size,
            fit: BoxFit.cover,
            // If the server 404s or any error occurs, show placeholder.
            errorBuilder: (_, __, ___) => _placeholder(size, cs),
          )
        : Image.asset(
            src,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(size, cs),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: size, height: size, child: image),
    );
  }

  Widget _placeholder(double size, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_not_supported, color: cs.onSurfaceVariant),
    );
  }
}
