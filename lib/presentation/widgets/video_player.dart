import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Conditional import for iframe support
import 'video_player_iframe_stub.dart'
    if (dart.library.html) 'video_player_iframe_web.dart'
    as iframe_impl;

/// Reusable in-app video player.
/// Supports YouTube and iframe-based video embeds (Cloudflare Stream, Vimeo, etc.)
/// Works on both web and mobile platforms.
class VideoPlayer extends StatefulWidget {
  /// Provide either a full video URL, embed URL, or YouTube video ID.
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

  /// Check if the URL is a YouTube URL
  static bool isYoutubeUrl(String input) {
    final lower = input.toLowerCase();
    return lower.contains('youtube.com') ||
        lower.contains('youtu.be') ||
        RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(input);
  }

  /// Check if the URL is an iframe embed URL (ends with /iframe or similar)
  static bool isIframeUrl(String input) {
    final lower = input.toLowerCase();
    return lower.contains('/iframe') ||
        lower.contains('cloudflarestream.com') ||
        lower.contains('player.vimeo.com');
  }

  /// Extracts a YouTube video id from a url or returns the input if it already
  /// looks like an id. Returns null if it can't parse.
  static String? parseYoutubeId(String input) {
    if (kDebugMode) {
      print('🎬 VideoPlayer: Parsing YouTube ID from: $input');
    }

    // Already looks like an id (11 chars, alphanumeric with _ and -)
    final idLike = RegExp(r'^[A-Za-z0-9_-]{11}$');
    if (idLike.hasMatch(input)) {
      if (kDebugMode) print('🎬 VideoPlayer: Input is already a valid ID');
      return input;
    }

    // Only try to parse if it looks like a YouTube URL
    if (!isYoutubeUrl(input)) {
      if (kDebugMode) print('🎬 VideoPlayer: Not a YouTube URL');
      return null;
    }

    try {
      final uri = Uri.parse(input);

      // Check ?v=ID parameter (youtube.com/watch?v=ID)
      final v = uri.queryParameters['v'];
      if (v != null && idLike.hasMatch(v)) {
        if (kDebugMode) print('🎬 VideoPlayer: Found ID in ?v= param: $v');
        return v;
      }

      // Check for /embed/ID pattern
      final embedMatch = RegExp(
        r'/embed/([A-Za-z0-9_-]{11})',
      ).firstMatch(input);
      if (embedMatch != null) {
        final id = embedMatch.group(1);
        if (kDebugMode) print('🎬 VideoPlayer: Found ID in /embed/ path: $id');
        return id;
      }

      // Check for /shorts/ID pattern
      final shortsMatch = RegExp(
        r'/shorts/([A-Za-z0-9_-]{11})',
      ).firstMatch(input);
      if (shortsMatch != null) {
        final id = shortsMatch.group(1);
        if (kDebugMode) print('🎬 VideoPlayer: Found ID in /shorts/ path: $id');
        return id;
      }

      // Check for youtu.be/ID pattern
      if (uri.host.contains('youtu.be')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty && idLike.hasMatch(pathSegments.first)) {
          if (kDebugMode) {
            print(
              '🎬 VideoPlayer: Found ID in youtu.be path: ${pathSegments.first}',
            );
          }
          return pathSegments.first;
        }
      }
    } catch (e) {
      if (kDebugMode) print('🎬 VideoPlayer: Error parsing URL: $e');
    }

    if (kDebugMode) print('🎬 VideoPlayer: Could not extract YouTube ID');
    return null;
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  YoutubePlayerController? _yt;
  WebViewController? _webViewController;
  String? _iframeViewType;
  bool _isIframeEmbed = false;
  bool _useWebView = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final url = widget.youtubeIdOrUrl;

    // Check if this is a YouTube video
    if (VideoPlayer.isYoutubeUrl(url)) {
      final id = VideoPlayer.parseYoutubeId(url);
      if (id != null) {
        if (kDebugMode) {
          print('🎬 VideoPlayer: Creating YouTube controller for ID: $id');
        }
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
        return;
      }
    }

    // For non-YouTube URLs (Cloudflare Stream, etc.)
    if (VideoPlayer.isIframeUrl(url) || url.startsWith('http')) {
      if (kDebugMode) {
        print('🎬 VideoPlayer: Setting up video embed for: $url');
      }

      // On web, use iframe
      if (kIsWeb) {
        _isIframeEmbed = true;
        _iframeViewType = 'video-iframe-${url.hashCode}';
        iframe_impl.registerIframeView(_iframeViewType!, url);
      } else {
        // On mobile, use WebView
        _useWebView = true;
        _initWebView(url);
      }
    }
  }

  void _initWebView(String url) {
    if (kDebugMode) {
      print('🎬 VideoPlayer: Initializing WebView for: $url');
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (kDebugMode && progress % 25 == 0) {
              print('🎬 VideoPlayer: WebView loading progress: $progress%');
            }
          },
          onPageStarted: (String url) {
            if (kDebugMode) {
              print('🎬 VideoPlayer: Page started loading: $url');
            }
          },
          onPageFinished: (String url) {
            if (kDebugMode) {
              print('🎬 VideoPlayer: Page finished loading: $url');
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print('🎬 VideoPlayer: WebView error: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  void dispose() {
    _yt?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // YouTube player (works on both web and mobile)
    if (_yt != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(controller: _yt!),
      );
    }

    // Web: Iframe embed (Cloudflare Stream, Vimeo, etc.)
    if (_isIframeEmbed && _iframeViewType != null && kIsWeb) {
      final iframeWidget = iframe_impl.buildIframeWidget(_iframeViewType!);
      if (iframeWidget != null) {
        return AspectRatio(aspectRatio: 16 / 9, child: iframeWidget);
      }
    }

    // Mobile: WebView for iframe embeds
    if (_useWebView && _webViewController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: WebViewWidget(controller: _webViewController!),
      );
    }

    // Fallback placeholder
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: cs.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: cs.onSurfaceVariant, size: 48),
            const SizedBox(height: 8),
            Text(
              'Video unavailable',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
