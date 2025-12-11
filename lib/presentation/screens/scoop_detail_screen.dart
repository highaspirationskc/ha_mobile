// lib/presentation/screens/scoop_detail_screen.dart
import 'package:flutter/foundation.dart';
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
  void initState() {
    super.initState();
    _logVideoInfo();
  }

  void _logVideoInfo() {
    if (kDebugMode) {
      final s = widget.scoop;
      print('🎥 Scoop Video Info:');
      print('   Title: ${s.title}');
      print('   videoUrl: ${s.videoUrl}');
      print('   videoEmbedUrl: ${s.videoEmbedUrl}');
      print('   youtubeId (extracted): ${s.youtubeId}');
      print('   thumbnailUrl: ${s.thumbnailUrl}');
    }
  }

  /// Get the best video URL to use for the player
  /// Prefer videoEmbedUrl (usually YouTube embed format), then videoUrl
  String? get _playableUrl {
    final s = widget.scoop;
    return s.videoEmbedUrl ?? s.videoUrl;
  }

  /// Check if we have any video to play
  bool get _hasVideo => _playableUrl != null && _playableUrl!.isNotEmpty;

  void _handlePlay() {
    if (kDebugMode) {
      print('🎥 Play button pressed');
      print('   playableUrl: $_playableUrl');
    }

    if (_hasVideo) {
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = widget.scoop;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header: either 16:9 thumbnail with play overlay OR in-app player
        if (!_playing)
          _HeaderImageWithPlay(
            imageUrl: s.thumbnailUrl,
            onPlay: _hasVideo ? _handlePlay : null,
          )
        else if (_playableUrl != null)
          // Pass the full URL - VideoPlayer will extract the YouTube ID
          VideoPlayer(youtubeIdOrUrl: _playableUrl!, autoPlay: true)
        else
          _HeaderImageWithPlay(imageUrl: s.thumbnailUrl, onPlay: null),

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

              if (s.description != null && s.description!.isNotEmpty) ...[
                Text(
                  'About',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(s.description!, style: t.bodyLarge),
              ],
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
