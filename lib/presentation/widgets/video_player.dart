import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Reusable in-app video player.
/// Currently supports YouTube. Extend later for file/HLS sources if needed.
class VideoPlayer extends StatefulWidget {
  /// Provide either a full YouTube URL or the 11-char videoId.
  final String youtubeIdOrUrl;

  /// Autoplay once rendered.
  final bool autoPlay;

  const VideoPlayer({
    super.key,
    required this.youtubeIdOrUrl,
    this.autoPlay = true,
  });

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();

  /// Extracts a YouTube video id from a url or returns the input if it already
  /// looks like an id. Returns null if it can't parse.
  static String? parseYoutubeId(String input) {
    // already looks like an id
    final idLike = RegExp(r'^[A-Za-z0-9_-]{11}$');
    if (idLike.hasMatch(input)) return input;

    try {
      final uri = Uri.parse(input);
      // common patterns: ?v=ID, youtu.be/ID, /embed/ID
      final v = uri.queryParameters['v'];
      if (v != null && idLike.hasMatch(v)) return v;

      final path = uri.path; // e.g. /watch, /embed/ID, /ID
      final m = RegExp(
        r'(?:/embed/|/shorts/|/)([A-Za-z0-9_-]{11})',
      ).firstMatch(path);
      if (m != null && m.groupCount >= 1) return m.group(1);
    } catch (_) {}
    return null;
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  YoutubePlayerController? _yt;

  @override
  void initState() {
    super.initState();
    final id = VideoPlayer.parseYoutubeId(widget.youtubeIdOrUrl);
    if (id != null) {
      _yt = YoutubePlayerController.fromVideoId(
        videoId: id,
        autoPlay: widget.autoPlay,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          strictRelatedVideos: true,
          enableCaption: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we couldn't parse a YouTube id, show a graceful placeholder.
    if (_yt == null) {
      final cs = Theme.of(context).colorScheme;
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: cs.surfaceVariant,
          alignment: Alignment.center,
          child: Icon(Icons.play_circle_fill, color: cs.primary, size: 48),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(controller: _yt!),
    );
  }
}
