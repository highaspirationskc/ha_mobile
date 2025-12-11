class Scoop {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? imageUrl;
  final String? imageThumbnailUrl;
  final String? videoUrl;
  final String? videoEmbedUrl;
  final String? videoThumbnailUrl;
  final DateTime? publishOn;
  final bool published;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Scoop({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.imageUrl,
    this.imageThumbnailUrl,
    this.videoUrl,
    this.videoEmbedUrl,
    this.videoThumbnailUrl,
    this.publishOn,
    this.published = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Scoop.fromJson(Map<String, dynamic> json) {
    return Scoop(
      id: json['id'].toString(),
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      imageThumbnailUrl: json['imageThumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoEmbedUrl: json['videoEmbedUrl'] as String?,
      videoThumbnailUrl: json['videoThumbnailUrl'] as String?,
      publishOn: json['publishOn'] != null
          ? DateTime.parse(json['publishOn'] as String)
          : null,
      published: json['published'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'imageUrl': imageUrl,
      'imageThumbnailUrl': imageThumbnailUrl,
      'videoUrl': videoUrl,
      'videoEmbedUrl': videoEmbedUrl,
      'videoThumbnailUrl': videoThumbnailUrl,
      'publishOn': publishOn?.toIso8601String().split('T')[0],
      'published': published,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// The date to use for display - publishOn if available, otherwise createdAt
  DateTime get datePosted => publishOn ?? createdAt;

  /// Attempts to pull the YouTube video id from [videoUrl] or [videoEmbedUrl].
  /// Works for links like:
  /// - https://www.youtube.com/watch?v=<id>
  /// - https://youtu.be/<id>
  /// - https://www.youtube.com/embed/<id>
  String? get youtubeId {
    // Try videoUrl first, then videoEmbedUrl
    final urls = [videoUrl, videoEmbedUrl];

    for (final url in urls) {
      if (url == null || url.isEmpty) continue;

      final id = _extractYoutubeId(url);
      if (id != null) return id;
    }
    return null;
  }

  String? _extractYoutubeId(String url) {
    try {
      final uri = Uri.parse(url);

      // Check query parameter ?v=ID
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty && _isValidYoutubeId(v)) return v;

      // Check for /embed/ID, /shorts/ID, or youtu.be/ID patterns
      final embedMatch = RegExp(
        r'(?:/embed/|/shorts/)([A-Za-z0-9_-]{11})',
      ).firstMatch(url);
      if (embedMatch != null) return embedMatch.group(1);

      // Check for youtu.be/ID
      if (uri.host.contains('youtu.be')) {
        final pathId = uri.path.replaceFirst('/', '');
        if (_isValidYoutubeId(pathId)) return pathId;
      }

      // General pattern match
      final r = RegExp(r'(?:v=|youtu\.be/)([A-Za-z0-9_-]{11})');
      final m = r.firstMatch(url);
      if (m != null && m.groupCount >= 1) return m.group(1);
    } catch (_) {}
    return null;
  }

  bool _isValidYoutubeId(String id) {
    return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id);
  }

  /// Thumbnail URL - prefer API-provided, fallback to YouTube thumbnail
  String? get thumbnailUrl {
    // Prefer API-provided thumbnails
    if (videoThumbnailUrl != null && videoThumbnailUrl!.isNotEmpty) {
      return videoThumbnailUrl;
    }
    if (imageThumbnailUrl != null && imageThumbnailUrl!.isNotEmpty) {
      return imageThumbnailUrl;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl;
    }
    // Fallback to YouTube thumbnail
    final id = youtubeId;
    if (id == null) return null;
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scoop && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Scoop(id: $id, title: $title, author: $author, published: $published)';
  }
}
