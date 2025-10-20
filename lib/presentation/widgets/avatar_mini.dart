// lib/presentation/widgets/avatar_mini.dart
import 'package:flutter/material.dart';

class AvatarMini extends StatelessWidget {
  /// Network URL or assets/... path. If null/empty or fails, falls back to initials.
  final String? imageUrl;

  /// Optional initials to show when no image. e.g. "AB"
  final String? initials;

  /// Optional solid background color used behind initials.
  final Color? color;

  /// Diameter in logical pixels.
  final double size;

  const AvatarMini({
    super.key,
    this.imageUrl,
    this.initials,
    this.color,
    this.size = 24,
  });

  bool get _isNetwork =>
      (imageUrl != null &&
      imageUrl!.isNotEmpty &&
      imageUrl!.startsWith('http'));

  bool get _isAsset =>
      (imageUrl != null &&
      imageUrl!.isNotEmpty &&
      !imageUrl!.startsWith('http'));

  @override
  Widget build(BuildContext context) {
    // Outer white ring (2px)
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: _buildInner(context)),
    );
  }

  Widget _buildInner(BuildContext context) {
    final fallback = _InitialsChip(
      text: _safeInitials(initials),
      color: color ?? Theme.of(context).colorScheme.primaryContainer,
      size: size - 4, // account for 2px border padding on each side
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    if (_isNetwork) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (_isAsset) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return fallback;
  }

  String _safeInitials(String? s) {
    if (s == null || s.trim().isEmpty) return '';
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    final a = parts.first.characters.firstOrNull ?? '';
    final b = parts.last.characters.firstOrNull ?? '';
    return (a + b).toUpperCase();
  }
}

class _InitialsChip extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  const _InitialsChip({
    required this.text,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontSize: (size * 0.42),
          fontWeight: FontWeight.w700,
          color: _bestOnColor(color, cs),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // Very simple contrast heuristic for text color on the chip
  Color _bestOnColor(Color bg, ColorScheme cs) {
    // YIQ luma
    final yiq = ((bg.red * 299) + (bg.green * 587) + (bg.blue * 114)) / 1000;
    return yiq >= 160 ? Colors.black : Colors.white;
  }
}
