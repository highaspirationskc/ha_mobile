import 'package:flutter/material.dart';
import '../../business/scoops/entities/scoop.dart';

class SaturdayScoopSmall extends StatelessWidget {
  final Scoop scoop;
  final VoidCallback? onTap;

  const SaturdayScoopSmall({super.key, required this.scoop, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 8,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Bottom layer: Scoop thumbnail (fills entire space)
                  Positioned.fill(child: _buildThumbnail()),

                  // Middle layer: Dark overlay (no gradient, solid dark)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),

                  // Top layer: Title at bottom
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Text(
                      scoop.title,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildThumbnail() {
    // Use YouTube thumbnail if available
    final thumbnailUrl = scoop.thumbnailUrl;

    Widget placeholder() => Container(
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(
        Icons.play_circle_outline,
        color: Colors.white,
        size: 48,
      ),
    );

    if (thumbnailUrl == null || thumbnailUrl.trim().isEmpty) {
      return placeholder();
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(), // Empty container to handle errors gracefully
    );
  }
}
