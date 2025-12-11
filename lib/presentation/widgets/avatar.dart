import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/color_schemes.dart';

/// Displays a circular user avatar.
/// Priority: image > initials on colored background.
/// If [editable] is true, tapping opens actions: take photo, choose photo, choose color, remove photo.
class Avatar extends StatefulWidget {
  final String? firstName;
  final String? lastName;

  /// Image can be a local file path, an 'assets/...' path, or an http/https URL.
  final String? image;

  /// Image bytes for preview (used on web before upload completes).
  final Uint8List? imageBytes;

  /// Selected profile color index (0..kProfileColors.length-1). Used when no image.
  final int? colorIndex;

  /// Callback when image is picked. Returns the XFile for further processing.
  final ValueChanged<XFile?>? onImagePicked;

  /// Callback when the image path/URL changes. null = remove.
  final ValueChanged<String?>? onImageChanged;

  /// Callback when the color index changes.
  final ValueChanged<int>? onColorChanged;

  /// Size in logical px (diameter).
  final double size;

  /// Shows an edit pen overlay & enables tap actions when true.
  final bool editable;

  /// Shows a loading indicator over the avatar.
  final bool isLoading;

  const Avatar({
    super.key,
    this.firstName,
    this.lastName,
    this.image,
    this.imageBytes,
    this.colorIndex,
    this.onImagePicked,
    this.onImageChanged,
    this.onColorChanged,
    this.size = 72,
    this.editable = false,
    this.isLoading = false,
  });

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveColor();
    final initials = _buildInitials();

    Widget child;

    // Priority: imageBytes (preview) > image URL/path > initials
    if (widget.imageBytes != null) {
      child = Image.memory(
        widget.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if ((widget.image ?? '').trim().isNotEmpty) {
      child = _buildImage(widget.image!);
    } else {
      child = Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: widget.size * 0.36,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    Widget avatar = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: (widget.image ?? '').isEmpty && widget.imageBytes == null
            ? bgColor
            : null,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    // Show loading overlay if uploading
    if (widget.isLoading) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!widget.editable) return avatar;

    // Editable: add small pen overlay + tap
    return Stack(
      alignment: Alignment.center,
      children: [
        avatar,
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: widget.size * 0.28,
            height: widget.size * 0.28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Icon(Icons.edit, size: 14),
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _showEditSheet,
            ),
          ),
        ),
      ],
    );
  }

  // ---- Helpers ----

  String _buildInitials() {
    final f = (widget.firstName ?? '').trim();
    final l = (widget.lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    if (f.isEmpty) return l.characters.first.toUpperCase();
    if (l.isEmpty) return f.characters.first.toUpperCase();
    return (f.characters.first + l.characters.first).toUpperCase();
  }

  Color _resolveColor() {
    final idx =
        widget.colorIndex ??
        (_hashName(widget.firstName, widget.lastName) % kProfileColors.length);
    return kProfileColors[idx.clamp(0, kProfileColors.length - 1)];
  }

  int _hashName(String? f, String? l) {
    final s = '${f ?? ''}|${l ?? ''}';
    var h = 0;
    for (final c in s.codeUnits) {
      h = 0x1fffffff & (h + c);
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h.abs();
  }

  Widget _buildImage(String src) {
    final isNetwork = src.startsWith('http');
    final isAsset = src.startsWith('assets/');
    if (isNetwork) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (isAsset) {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else if (!kIsWeb) {
      // File path - only works on native platforms
      return Image.file(
        File(src),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      // On web with a file path, show fallback (should use imageBytes instead)
      return _fallback();
    }
  }

  Widget _fallback() {
    // If image fails, show initials on resolved color
    final bg = _resolveColor();
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        _buildInitials(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: widget.size * 0.36,
        ),
      ),
    );
  }

  Future<void> _showEditSheet() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final x = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 90,
                  );
                  if (x != null) {
                    // Prefer onImagePicked for better cross-platform handling
                    if (widget.onImagePicked != null) {
                      widget.onImagePicked!(x);
                    } else {
                      widget.onImageChanged?.call(x.path);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final x = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 90,
                  );
                  if (x != null) {
                    // Prefer onImagePicked for better cross-platform handling
                    if (widget.onImagePicked != null) {
                      widget.onImagePicked!(x);
                    } else {
                      widget.onImageChanged?.call(x.path);
                    }
                  }
                },
              ),
              if ((widget.image ?? '').isNotEmpty || widget.imageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (widget.onImagePicked != null) {
                      widget.onImagePicked!(null);
                    } else {
                      widget.onImageChanged?.call(null);
                    }
                  },
                ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose color',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
              _ColorGrid(
                selectedIndex: widget.colorIndex,
                onSelected: (i) {
                  widget.onColorChanged?.call(i);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  const _ColorGrid({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (int i = 0; i < kProfileColors.length; i++)
            GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kProfileColors[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selectedIndex
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: i == selectedIndex
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
