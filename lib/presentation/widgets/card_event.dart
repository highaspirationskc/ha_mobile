import 'package:flutter/material.dart';
import 'package:ha_mobile/core/routes.dart';

import 'package:ha_mobile/core/session.dart'; // kCurrentUserId
import '../../business/events/entities/event.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/date_formatters.dart';
import '../../business/user/entities/user.dart';

import 'avatar_mini.dart';
import 'button_round_small.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _loadingStatus = true;
  bool _registered = false;
  bool _checkedIn = false;

  bool _registering = false;
  bool _checkingIn = false;

  void _onServiceChange() {
    _loadState(); // refresh when service signals change
  }

  @override
  void initState() {
    super.initState();
    _loadState();
    ApiService.instance.changes.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onServiceChange);
    super.dispose();
  }

  Future<void> _loadState() async {
    final isReg = await ApiService.instance.isRegistered(
      eventId: widget.event.id,
      userId: kCurrentUserId,
    );
    final isIn = await ApiService.instance.isCheckedIn(
      eventId: widget.event.id,
      userId: kCurrentUserId,
    );
    if (!mounted) return;
    setState(() {
      _registered = isReg;
      _checkedIn = isIn;
      _loadingStatus = false;
    });
  }

  Future<void> _onPrimaryAction() async {
    // Register
    if (!_registered) {
      if (_registering) return;
      setState(() => _registering = true);
      try {
        await ApiService.instance.registerForEvent(
          eventId: widget.event.id,
          userId: kCurrentUserId,
        );
        ApiService.instance.changes.value++; // broadcast to others
        if (!mounted) return;
        await _loadState(); // ensure fresh state locally
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You’re registered!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
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
      return;
    }

    // Check-in
    if (_registered && !_checkedIn) {
      final ok = await Navigator.of(context).pushNamed(
        AppRoutes.checkInScanner,
        arguments: widget.event.id, // pass id so mock scan targets this event
      );
      if (!mounted) return;
      if (ok == true) {
        await _loadState(); // refresh after completing sheet
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final e = widget.event;

    final actionLabel = _loadingStatus
        ? '...'
        : (!_registered
              ? 'Register'
              : (!_checkedIn ? 'Check-in' : 'Checked in'));
    final actionLoading = _loadingStatus || _registering || _checkingIn;
    final actionEnabled = !_loadingStatus && !(_registered && _checkedIn);

    final List<User> shown = e.attendees.take(3).toList();
    final int extra = (e.attendeeCount - shown.length).clamp(0, 999);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (inset, rounded, 16:9)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _HeaderImage(src: e.image),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (_registered) ...[
                            const SizedBox(width: 8),
                            const _RegisteredBadgeTiny(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Date/time & Location
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${formatShortDate(e.dateTime)} • ${formatTime(e.dateTime)}',
                            style: t.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              e.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Attendees + action
                      Row(
                        children: [
                          _AttendingStripUsers(users: shown, extraCount: extra),
                          const Spacer(),
                          ButtonRoundSmall(
                            label: actionLabel,
                            onPressed: actionEnabled ? _onPrimaryAction : null,
                            isLoading: actionLoading,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- pieces ---

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

class _RegisteredBadgeTiny extends StatelessWidget {
  const _RegisteredBadgeTiny();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: cs.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            'Registered',
            style: t.labelSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendingStripUsers extends StatelessWidget {
  final List<User> users; // up to 3 shown
  final int extraCount; // remaining attendees beyond shown avatars
  const _AttendingStripUsers({required this.users, required this.extraCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // width for overlapping avatars (24px circles with 6px overlap -> 18px step)
    final width = users.isEmpty ? 0.0 : (24 + (users.length - 1) * 18.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (users.isNotEmpty)
          SizedBox(
            height: 24,
            width: width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < users.length; i++)
                  Positioned(
                    left: i * 18.0,
                    child: AvatarMini(imageUrl: users[i].image ?? ''),
                  ),
              ],
            ),
          ),

        if (users.isNotEmpty && extraCount > 0) const SizedBox(width: 6),

        if (extraCount > 0)
          Container(
            height: 24,
            constraints: const BoxConstraints(minWidth: 24),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '+$extraCount',
              style: t.labelSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}
