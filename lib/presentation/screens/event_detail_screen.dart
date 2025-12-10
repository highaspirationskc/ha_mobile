// lib/presentation/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:ha_mobile/core/routes.dart';

import '../../business/events/entities/event.dart';
import '../../business/user/entities/user.dart';
import '../../core/utils/date_formatters.dart';
import '../../data/services/api_service.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/session.dart';
import '../widgets/button_long.dart';
import '../widgets/button_long_outlined.dart';
import '../widgets/avatar.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _loadingStatus = true;
  bool _registered = false;
  bool _checkedIn = false;

  bool _registering = false;
  bool _checkingIn = false;
  bool _unregistering = false;

  /// Get fresh event from service if available, fallback to widget.event
  Event get _event =>
      OlympicSeasonService.instance.getEventById(widget.event.id) ??
      widget.event;

  @override
  void initState() {
    super.initState();
    _logRegisteredUsers();
    _loadState();
    ApiService.instance.changes.addListener(_onServiceChange);
    OlympicSeasonService.instance.addListener(_onSeasonChange);
  }

  void _logRegisteredUsers() {
    print('📋 Event: ${_event.name}');
    print('📋 Registered Users (${_event.registeredUsers.length}):');
    for (final user in _event.registeredUsers) {
      print(
        '   - ID: ${user.id}, Name: ${user.firstName} ${user.lastName}, Image: ${user.image}',
      );
    }
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onServiceChange);
    OlympicSeasonService.instance.removeListener(_onSeasonChange);
    super.dispose();
  }

  void _onServiceChange() {
    _loadState(); // pull fresh flags whenever service notifies
  }

  void _onSeasonChange() {
    // Refresh when Olympic Season data updates (after registration/check-in)
    if (mounted) setState(() {});
    _loadState();
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
      // User is registered if either source says so
      _registered = isRegFromEvent || isRegFromCache;
      _checkedIn = isInFromEvent || isInFromCache;
      _loadingStatus = false;
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
      ApiService.instance.changes.value++; // broadcast
      if (!mounted) return;
      await _loadState(); // re-pull fresh state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You’re registered!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    setState(() => _checkingIn = true);

    final ok = await Navigator.of(context).pushNamed(
      AppRoutes.checkInScanner,
      arguments: widget.event.id, // let mock scan line up with this event
    );

    if (!mounted) return;
    setState(() => _checkingIn = false);

    if (ok == true) {
      await _loadState(); // refresh status from service
    }
  }

  Future<void> _onCancelRegistration() async {
    if (_unregistering || !_registered) return;
    setState(() => _unregistering = true);
    try {
      await ApiService.instance.unregister(
        eventId: widget.event.id,
        userId: currentUserId,
      );
      ApiService.instance.changes.value++; // broadcast
      if (!mounted) return;
      await _loadState(); // refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration cancelled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      if (mounted) setState(() => _unregistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = _event;

    // Show all attendees in a grid
    final List<User> allAttendees = e.registeredUsers;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Full-bleed header image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _HeaderImage(src: e.imageUrl ?? ''),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Registered badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      e.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_registered || _checkedIn) ...[
                    const SizedBox(width: 8),
                    _StatusBadge(isCheckedIn: _checkedIn),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              _InfoRow(
                icon: Icons.calendar_today_outlined,
                primary: formatLongDate(e.eventDate),
                secondary: formatTime(e.eventDate),
              ),
              const _SectionDivider(),

              _InfoRow(icon: Icons.place_outlined, primary: e.location ?? ''),
              const _SectionDivider(),

              // About
              Text(
                'About',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(e.description ?? '', style: textTheme.bodyLarge),

              // ---- Attending (between About and buttons) ----
              const SizedBox(height: 24),
              Text(
                'Attending',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _AttendeesGrid(attendees: allAttendees),
              const SizedBox(height: 24),

              // ---- Actions ----
              if (_loadingStatus)
                ButtonLong(label: 'Loading…', onPressed: null, isLoading: true)
              else if (!_registered) ...[
                ButtonLong(
                  label: _registering ? 'Registering…' : 'Register',
                  icon: Icons.event_available_outlined,
                  isLoading: _registering,
                  onPressed: _registering ? null : _onRegister,
                ),
              ] else ...[
                // Primary: Check-in
                ButtonLong(
                  label: _checkedIn
                      ? 'Checked In'
                      : (_checkingIn ? 'Checking in…' : 'Check-in'),
                  icon: _checkedIn ? Icons.check_circle : Icons.login,
                  isLoading: _checkingIn,
                  onPressed: (_checkingIn || _checkedIn) ? null : _onCheckIn,
                  style: _checkedIn
                      ? FilledButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                // Secondary: Cancel registration
                ButtonLongOutlined(
                  label: _unregistering ? 'Cancelling…' : 'Cancel registration',
                  icon: Icons.cancel_outlined,
                  isLoading: _unregistering,
                  onPressed: _unregistering ? null : _onCancelRegistration,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCheckedIn;
  const _StatusBadge({required this.isCheckedIn});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Use green for arrived, primary for registered
    final bgColor = isCheckedIn ? Colors.green.shade50 : cs.primaryContainer;
    final fgColor = isCheckedIn ? Colors.green.shade700 : cs.onPrimaryContainer;
    final borderColor = isCheckedIn
        ? Colors.green.shade200
        : cs.primary.withOpacity(0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCheckedIn ? Icons.check_circle : Icons.verified,
            size: 14,
            color: fgColor,
          ),
          const SizedBox(width: 4),
          Text(
            isCheckedIn ? 'Arrived' : 'Registered',
            style: t.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String src;
  const _HeaderImage({required this.src});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget placeholder() => Container(
      color: cs.surfaceVariant,
      alignment: Alignment.center,
      child: Icon(Icons.image, color: cs.primary),
    );
    final isNetwork = src.startsWith('http');
    if (src.trim().isEmpty) return placeholder();
    return isNetwork
        ? Image.network(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder(),
          )
        : Image.asset(
            src,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder(),
          );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String primary;
  final String? secondary;
  const _InfoRow({required this.icon, required this.primary, this.secondary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (secondary != null) ...[
                const SizedBox(height: 2),
                Text(
                  secondary!,
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: cs.outlineVariant),
    );
  }
}

/// Grid layout showing attendees with show more/less functionality
class _AttendeesGrid extends StatefulWidget {
  final List<User> attendees;
  const _AttendeesGrid({required this.attendees});

  @override
  State<_AttendeesGrid> createState() => _AttendeesGridState();
}

class _AttendeesGridState extends State<_AttendeesGrid> {
  bool _showAll = false;
  static const int _maxInitial = 10;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (widget.attendees.isEmpty) {
      return Text(
        'No attendees yet',
        style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      );
    }

    final attendeesToShow = _showAll
        ? widget.attendees
        : widget.attendees.take(_maxInitial).toList();
    final remainingCount = widget.attendees.length - _maxInitial;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: attendeesToShow.length,
          itemBuilder: (context, index) {
            final user = attendeesToShow[index];
            return Avatar(
              firstName: user.firstName,
              lastName: user.lastName,
              image: user.image,
              size: 48,
            );
          },
        ),
        if (widget.attendees.length > _maxInitial) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAll = !_showAll;
                });
              },
              child: Text(
                _showAll ? 'Show Less' : 'Show More (+$remainingCount)',
                style: t.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
