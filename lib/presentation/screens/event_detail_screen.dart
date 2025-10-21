// lib/presentation/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:ha_mobile/core/routes.dart';

import '../../business/events/entities/event.dart';
import '../../business/user/entities/user.dart';
import '../../core/utils/date_formatters.dart';
import '../../data/services/api_service.dart';
import '../../core/session.dart'; // kCurrentUserId
import '../widgets/button_long.dart';
import '../widgets/button_long_outlined.dart';
import '../widgets/avatar_mini.dart';

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

  @override
  void initState() {
    super.initState();
    _loadState();
    ApiService.instance.changes.addListener(
      _onServiceChange,
    ); // listen for global updates
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    _loadState(); // pull fresh flags whenever service notifies
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

  Future<void> _onRegister() async {
    if (_registering || _registered) return;
    setState(() => _registering = true);
    try {
      await ApiService.instance.registerForEvent(
        eventId: widget.event.id,
        userId: kCurrentUserId,
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
        userId: kCurrentUserId,
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
    final cs = Theme.of(context).colorScheme;
    final e = widget.event;

    // Prepare attendees for the strip
    final List<User> shown = e.attendees.take(6).toList(); // show up to 6 here
    final int extra = (e.attendeeCount - shown.length).clamp(0, 999);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Full-bleed header image
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _HeaderImage(src: e.image),
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
                  if (_registered) ...[
                    const SizedBox(width: 8),
                    const _RegisteredBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              _InfoRow(
                icon: Icons.calendar_today_outlined,
                primary: formatLongDate(e.dateTime),
                secondary: formatTime(e.dateTime),
              ),
              const _SectionDivider(),

              _InfoRow(icon: Icons.place_outlined, primary: e.location),
              const _SectionDivider(),

              // About
              Text(
                'About',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(e.description, style: textTheme.bodyLarge),

              // ---- Attending (between About and buttons) ----
              const SizedBox(height: 24),
              Text(
                'Attending',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _AttendeesStrip(users: shown, extraCount: extra),
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
                      ? 'Checked in'
                      : (_checkingIn ? 'Checking in…' : 'Check-in'),
                  icon: Icons.login,
                  isLoading: _checkingIn,
                  onPressed: (_checkingIn || _checkedIn) ? null : _onCheckIn,
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

class _RegisteredBadge extends StatelessWidget {
  const _RegisteredBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: cs.onPrimaryContainer),
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

/// Compact horizontally-overlapped avatar strip with "+N" badge
class _AttendeesStrip extends StatelessWidget {
  final List<User> users; // shown
  final int extraCount; // remaining attendees
  const _AttendeesStrip({required this.users, required this.extraCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // 24px avatars with 6px overlap => 18px step
    final width = users.isEmpty ? 0.0 : (24 + (users.length - 1) * 18.0);

    return Row(
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

        if (users.isNotEmpty && extraCount > 0) const SizedBox(width: 8),

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
            ),
          ),

        if (users.isEmpty && extraCount == 0)
          Text(
            'No attendees yet',
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}
