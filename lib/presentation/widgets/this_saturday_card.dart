import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/session.dart';
import '../../core/routes.dart';
import '../../data/services/api_service.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/theme/brand_colors.dart';
import '../../core/theme/color_schemes.dart';
import 'avatar_mini.dart';

class ThisSaturdayCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;

  const ThisSaturdayCard({super.key, required this.event, this.onTap});

  @override
  State<ThisSaturdayCard> createState() => _ThisSaturdayCardState();
}

class _ThisSaturdayCardState extends State<ThisSaturdayCard> {
  bool _registered = false;
  bool _checkedIn = false;
  bool _registering = false;

  /// Get fresh event from service if available, fallback to widget.event
  Event get _event =>
      OlympicSeasonService.instance.getEventById(widget.event.id) ??
      widget.event;

  void _onServiceChange() {
    _loadState();
  }

  void _onSeasonChange() {
    if (mounted) setState(() {});
    _loadState();
  }

  @override
  void initState() {
    super.initState();
    _loadState();
    ApiService.instance.changes.addListener(_onServiceChange);
    OlympicSeasonService.instance.addListener(_onSeasonChange);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onServiceChange);
    OlympicSeasonService.instance.removeListener(_onSeasonChange);
    super.dispose();
  }

  Future<void> _loadState() async {
    final e = _event;

    // Check from event's server data first
    final isRegFromEvent = e.isUserRegistered(currentUserId);
    final isInFromEvent = e.isUserCheckedIn(currentUserId);

    // Also check local cache (in case we just registered and haven't refetched)
    final isRegFromCache = await ApiService.instance.isRegistered(
      eventId: e.id,
      userId: currentUserId,
    );
    final isInFromCache = await ApiService.instance.isCheckedIn(
      eventId: e.id,
      userId: currentUserId,
    );

    if (!mounted) return;
    setState(() {
      _registered = isRegFromEvent || isRegFromCache;
      _checkedIn = isInFromEvent || isInFromCache;
    });
  }

  Future<void> _onRegister() async {
    if (_registering || _registered) return;
    setState(() => _registering = true);
    try {
      await ApiService.instance.registerForEvent(
        eventId: widget.event.id,
        userId: currentUserId,
      );
      ApiService.instance.changes.value++;
      if (!mounted) return;
      await _loadState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You\'re registered!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  Future<void> _onCheckIn() async {
    if (!_registered || _checkedIn) return;
    final ok = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.checkInScanner, arguments: widget.event.id);
    if (!mounted) return;
    if (ok == true) {
      await _loadState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final e = _event;

    return Material(
      color: kHAPrimary, // High Aspirations dark blue
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Content (50%)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event title
                    Text(
                      e.name,
                      style: t.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatShortDate(e.eventDate),
                          style: t.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            e.location ?? '',
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Attending avatars
                    if (e.registeredUsers.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _AttendingAvatars(attendees: e.registeredUsers),
                    ],

                    const SizedBox(height: 16),

                    // Action button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: !_registered
                            ? (_registering ? null : _onRegister)
                            : (!_checkedIn ? _onCheckIn : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _checkedIn
                              ? Colors.grey.shade200
                              : Colors.white,
                          foregroundColor: _checkedIn
                              ? Colors.grey.shade600
                              : const Color(0xFF2C3E5C),
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade600,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: _registering
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2C3E5C),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_checkedIn) ...[
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    !_registered
                                        ? 'Register'
                                        : (!_checkedIn
                                              ? 'Check-in'
                                              : 'Checked In'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right side - Image with badge (50%)
              Expanded(
                flex: 1,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 0.85, // Slightly taller than wide
                        child: SizedBox.expand(
                          child: _EventImage(src: e.imageUrl ?? ''),
                        ),
                      ),
                    ),
                    // Status badge overlay (Registered or Arrived)
                    if (_registered || _checkedIn)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _checkedIn
                                  ? Colors.green.shade50
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _checkedIn
                                      ? Icons.check_circle
                                      : Icons.verified,
                                  size: 14,
                                  color: _checkedIn
                                      ? Colors.green.shade700
                                      : const Color(0xFF2C3E5C),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _checkedIn ? 'Arrived' : 'Registered',
                                  style: t.labelSmall?.copyWith(
                                    color: _checkedIn
                                        ? Colors.green.shade700
                                        : const Color(0xFF2C3E5C),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  final String src;
  const _EventImage({required this.src});

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(0.1),
      alignment: Alignment.center,
      child: Icon(Icons.image, color: Colors.white.withOpacity(0.5), size: 32),
    );

    if (src.trim().isEmpty) return placeholder();

    final isNetwork = src.startsWith('http');
    return SizedBox.expand(
      child: isNetwork
          ? Image.network(
              src,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => placeholder(),
            )
          : Image.asset(
              src,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => placeholder(),
            ),
    );
  }
}

class _AttendingAvatars extends StatelessWidget {
  final List attendees;

  const _AttendingAvatars({required this.attendees});

  String _buildInitials(dynamic attendee) {
    final first = attendee.firstName ?? '';
    final last = attendee.lastName ?? '';
    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return last.substring(0, 1).toUpperCase();
    if (last.isEmpty) return first.substring(0, 1).toUpperCase();
    return '${first.substring(0, 1)}${last.substring(0, 1)}'.toUpperCase();
  }

  Color _getColor(int? colorIndex) {
    if (colorIndex == null ||
        colorIndex < 0 ||
        colorIndex >= kProfileColors.length) {
      return kProfileColors[0];
    }
    return kProfileColors[colorIndex];
  }

  @override
  Widget build(BuildContext context) {
    final displayedAttendees = attendees.take(3).toList();
    final remainingCount = attendees.length - displayedAttendees.length;

    // Calculate width: each avatar offset + final avatar size
    const double overlapOffset = 8.0; // Reduced from 20.0 for more overlap
    final avatarCount =
        displayedAttendees.length + (remainingCount > 0 ? 1 : 0);
    final stackWidth = (avatarCount - 1) * overlapOffset + 28.0;

    return SizedBox(
      height: 28,
      width: stackWidth,
      child: Stack(
        children: [
          for (int i = 0; i < displayedAttendees.length; i++)
            Positioned(
              left: i * overlapOffset,
              child: AvatarMini(
                imageUrl: displayedAttendees[i].image ?? '',
                initials: _buildInitials(displayedAttendees[i]),
                color: _getColor(displayedAttendees[i].colorIndex),
                strokeColor: kHAPrimary,
                size: 28,
              ),
            ),
          // Remaining count circle
          if (remainingCount > 0)
            Positioned(
              left: displayedAttendees.length * overlapOffset,
              child: Container(
                width: 28,
                height: 28,
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: kHAPrimary,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '+$remainingCount',
                      style: const TextStyle(
                        color: kHAPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
