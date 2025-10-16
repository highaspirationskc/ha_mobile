import 'dart:io' show File;
import 'package:flutter/material.dart';
import '../../core/theme/color_schemes.dart'; // for kProfileColors (your 12 profile colors)

class AvatarMini extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? image; // http(s) / assets/... / local file path
  final int? colorIndex; // optional index into kProfileColors
  final double size; // diameter
  final String? semanticsLabel;

  /// 2px white border by default as requested.
  final double borderWidth;
  final Color borderColor;

  const AvatarMini({
    super.key,
    this.firstName,
    this.lastName,
    this.image,
    this.colorIndex,
    this.size = 28,
    this.semanticsLabel,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final hasImg = (image ?? '').trim().isNotEmpty;

    return Semantics(
      label: semanticsLabel ?? _defaultSemantics(),
      image: hasImg,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias, // ensures the child is clipped to circle
        child: hasImg ? _buildImage() : _buildInitials(context),
      ),
    );
  }

  // --- helpers ---

  Widget _buildImage() {
    final src = image!.trim();
    final isNetwork = src.startsWith('http');
    final isAsset = src.startsWith('assets/');
    final img = isNetwork
        ? Image.network(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          )
        : isAsset
        ? Image.asset(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          )
        : Image.file(
            File(src),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          );

    // BoxFit.cover ensures the image fills the circular crop.
    return img;
  }

  Widget _buildInitials(BuildContext context) {
    final bg = _resolveColor(context);
    final initials = _initials(firstName, lastName);

    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.43,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _resolveColor(BuildContext context) {
    if (colorIndex != null && kProfileColors.isNotEmpty) {
      final i = colorIndex!.clamp(0, kProfileColors.length - 1);
      return kProfileColors[i];
    }
    // Fallback if no index provided: use a stable color from theme
    return Theme.of(context).colorScheme.secondaryContainer;
  }

  String _defaultSemantics() {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'User avatar';
    return 'Avatar of $f $l';
  }

  static String _initials(String? f, String? l) {
    final fn = (f ?? '').trim();
    final ln = (l ?? '').trim();
    if (fn.isEmpty && ln.isEmpty) return 'U';
    if (ln.isEmpty) return fn.characters.first.toUpperCase();
    if (fn.isEmpty) return ln.characters.first.toUpperCase();
    return (fn.characters.first + ln.characters.first).toUpperCase();
  }
}
