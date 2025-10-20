import 'package:flutter/material.dart';
import '../../business/scoops/entities/scoop.dart';
import '../../core/utils/date_formatters.dart';

class ListTileScoop extends StatelessWidget {
  final Scoop scoop;
  final VoidCallback? onTap;

  const ListTileScoop({super.key, required this.scoop, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8), // snug like your mock
          child: Row(
            children: [
              _ThumbWithPlay(url: scoop.thumbnailUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      scoop.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Author – Date
                    Text(
                      '${scoop.author} – ${formatShortDate(scoop.datePosted)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class _ThumbWithPlay extends StatelessWidget {
  final String? url;
  const _ThumbWithPlay({this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double thumbWidth = 104; // compact, matches your mock
    final borderRadius = BorderRadius.circular(8);

    Widget placeholder() => Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.play_circle_fill, color: cs.primary),
    );

    Widget thumbChild;
    if (url == null || url!.isEmpty) {
      thumbChild = placeholder();
    } else {
      thumbChild = Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder(),
            ),
          ),
          // Play overlay
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.85),
                width: 1,
              ),
            ),
            child: const Icon(Icons.play_arrow, size: 16, color: Colors.white),
          ),
        ],
      );
    }

    return SizedBox(
      width: thumbWidth,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(borderRadius: borderRadius, child: thumbChild),
      ),
    );
  }
}
