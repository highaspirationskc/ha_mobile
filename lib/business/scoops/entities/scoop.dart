import 'package:flutter/foundation.dart';

class Scoop {
  final String id;
  final String title;
  final String author;
  final String videoUrl;
  final String description;
  final Duration runtime;
  final DateTime datePosted;

  const Scoop({
    required this.id,
    required this.title,
    required this.author,
    required this.videoUrl,
    required this.description,
    required this.runtime,
    required this.datePosted,
  });

  /// Attempts to pull the YouTube video id from the [videoUrl].
  /// Works for links like: https://www.youtube.com/watch?v=<id>&...
  String? get youtubeId {
    try {
      final uri = Uri.parse(videoUrl);
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      // fallback: match common patterns
      final r = RegExp(r'(?:v=|youtu\.be/)([A-Za-z0-9_-]{11})');
      final m = r.firstMatch(videoUrl);
      if (m != null && m.groupCount >= 1) return m.group(1);
    } catch (_) {}
    return null;
  }

  /// High-quality YouTube thumbnail if we have a video id.
  String? get thumbnailUrl {
    final id = youtubeId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  /// Convenience for displaying mm:ss or h:mm:ss
  String get runtimeLabel {
    final total = runtime.inSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}
