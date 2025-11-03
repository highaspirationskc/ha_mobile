import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../core/utils/date_formatters.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final e = event;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Bottom layer: Event image
                  _EventImage(src: e.image),

                  // Middle layer: Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x33000000),
                          Color(0xCC000000),
                          Colors.black,
                        ],
                        stops: [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Top layer: Event info at bottom
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Event name
                        Text(
                          e.name,
                          style: t.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 20,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Time and Location (inline)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${formatShortDate(e.dateTime)} • ${formatTime(e.dateTime)}',
                              style: t.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.place,
                              size: 16,
                              color: Colors.white.withOpacity(0.95),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.location,
                                style: t.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    Widget placeholder() => Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(Icons.image, color: Colors.grey.shade600, size: 48),
    );

    if (src.trim().isEmpty) return placeholder();

    final isNetwork = src.startsWith('http');
    final isAsset = src.startsWith('assets/');

    if (isNetwork) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    } else if (isAsset) {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => placeholder(),
      );
    }

    return placeholder();
  }
}
