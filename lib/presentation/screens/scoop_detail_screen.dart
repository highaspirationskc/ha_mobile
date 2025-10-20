// lib/presentation/screens/scoop_detail_screen.dart
import 'package:flutter/material.dart';

import '../../business/scoops/entities/scoop.dart';
import '../../core/utils/date_formatters.dart';
import '../widgets/video_player.dart'; // <- reusable player

class ScoopDetailScreen extends StatefulWidget {
  final Scoop scoop;
  const ScoopDetailScreen({super.key, required this.scoop});

  @override
  State<ScoopDetailScreen> createState() => _ScoopDetailScreenState();
}

class _ScoopDetailScreenState extends State<ScoopDetailScreen> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = widget.scoop;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header: either 16:9 thumbnail with play overlay OR in-app player
        if (!_playing || s.youtubeId == null)
          _HeaderImageWithPlay(
            imageUrl: s.thumbnailUrl,
            onPlay: s.youtubeId == null
                ? null
                : () => setState(() => _playing = true),
          )
        else
          // You can pass either the id or the full URL; the widget parses both
          VideoPlayer(youtubeIdOrUrl: s.youtubeId!, autoPlay: true),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.title,
                style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${s.author} - ${formatLongDate(s.datePosted)}',
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: cs.outlineVariant),
              const SizedBox(height: 16),

              Text(
                'About',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(s.description, style: t.bodyLarge),
              const SizedBox(height: 12),

              // Runtime chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Runtime: ${s.runtimeLabel}',
                  style: t.labelMedium?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderImageWithPlay extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onPlay;
  const _HeaderImageWithPlay({required this.imageUrl, this.onPlay});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget placeholder() => Container(
      color: cs.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(Icons.play_circle_fill, color: cs.primary, size: 48),
    );

    final child = (imageUrl == null || imageUrl!.isEmpty)
        ? placeholder()
        : Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder(),
          );

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: child),
        if (onPlay != null)
          InkWell(
            onTap: onPlay,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
      ],
    );
  }
}
