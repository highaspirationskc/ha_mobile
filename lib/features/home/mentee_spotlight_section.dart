import 'dart:io';
import 'package:flutter/material.dart';
import '../../business/mentee_spotlight/entities/mentee_spotlight.dart';
import '../../business/user/entities/user_base.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/color_schemes.dart';

class MenteeSpotlightSection extends StatefulWidget {
  const MenteeSpotlightSection({super.key});

  @override
  State<MenteeSpotlightSection> createState() => _MenteeSpotlightSectionState();
}

class _MenteeSpotlightSectionState extends State<MenteeSpotlightSection> {
  MenteeSpotlight? _spotlight;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSpotlight();
  }

  Future<void> _loadSpotlight() async {
    try {
      final spotlight = await ApiService.instance.getMenteeSpotlight();
      if (mounted) {
        setState(() {
          _spotlight = spotlight;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_spotlight == null) {
      return const SizedBox.shrink();
    }

    final spotlight = _spotlight!;
    final mentee = spotlight.mentee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Spotlight',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        // Card
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: _isExpanded ? 280 : 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Bottom layer: Profile pic or centered initials
                  _buildProfileBackground(spotlight),

                  // Middle layer: Gradient overlay (transparent at top to black at bottom)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0x33000000),
                          const Color(0xCC000000),
                          Colors.black,
                          if (_isExpanded) Colors.black,
                        ],
                        stops: _isExpanded
                            ? [0.0, 0.3, 0.5, 0.7, 1.0]
                            : [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Top layer: Name and title in lower left corner
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Text(
                          '${mentee.firstName ?? ''} ${mentee.lastName ?? ''}'
                              .trim(),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Team name and points
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (spotlight.teamName != null) ...[
                              Text(
                                spotlight.teamName!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '  •  ',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                            Text(
                              '${spotlight.points} pts',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Expanded description
                        if (_isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            spotlight.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Tap indicator icon (chevron)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBackground(MenteeSpotlight spotlight) {
    // Use spotlight imageUrl first, then fall back to mentee's image
    final image = spotlight.imageUrl ?? spotlight.mentee.image;

    // If there's an image, display it
    if (image != null && image.trim().isNotEmpty) {
      final isNetwork = image.startsWith('http');
      final isAsset = image.startsWith('assets/');

      if (isNetwork) {
        return Image.network(
          image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) =>
              _buildInitialsBackground(spotlight.mentee),
        );
      } else if (isAsset) {
        return Image.asset(
          image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) =>
              _buildInitialsBackground(spotlight.mentee),
        );
      } else {
        // assume file path
        return Image.file(
          File(image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) =>
              _buildInitialsBackground(spotlight.mentee),
        );
      }
    }

    // Otherwise, show centered initials
    return _buildInitialsBackground(spotlight.mentee);
  }

  Widget _buildInitialsBackground(User mentee) {
    final initials = _buildInitials(mentee.firstName, mentee.lastName);
    final bgColor = _resolveColor(
      mentee.colorIndex,
      mentee.firstName,
      mentee.lastName,
    );

    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 80,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _buildInitials(String? firstName, String? lastName) {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    if (f.isEmpty) return l.characters.first.toUpperCase();
    if (l.isEmpty) return f.characters.first.toUpperCase();
    return (f.characters.first + l.characters.first).toUpperCase();
  }

  Color _resolveColor(int? colorIndex, String? firstName, String? lastName) {
    final idx =
        colorIndex ?? (_hashName(firstName, lastName) % kProfileColors.length);
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
}
