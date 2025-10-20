// lib/presentation/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../core/utils/date_formatters.dart';
import '../../data/services/api_service.dart';
import '../widgets/button_long.dart';
import '../widgets/button_long_outlined.dart';

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

  static const String _userId = 'current-user';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final isReg = await ApiService.instance.isRegistered(
      eventId: widget.event.id,
      userId: _userId,
    );
    final isIn = await ApiService.instance.isCheckedIn(
      eventId: widget.event.id,
      userId: _userId,
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
        userId: _userId,
      );
      if (!mounted) return;
      setState(() => _registered = true);
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
    if (_checkingIn || !_registered || _checkedIn) return;
    setState(() => _checkingIn = true);
    try {
      await ApiService.instance.checkInForEvent(
        eventId: widget.event.id,
        userId: _userId,
      );
      if (!mounted) return;
      setState(() => _checkedIn = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in!'),
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
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _onCancelRegistration() async {
    if (_unregistering || !_registered) return;
    setState(() => _unregistering = true);
    try {
      await ApiService.instance.unregister(
        eventId: widget.event.id,
        userId: _userId,
      );
      if (!mounted) return;
      setState(() {
        _registered = false;
        _checkedIn = false;
      });
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

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _HeaderImage(src: e.image),
        ),

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

              Text(
                'About',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(e.description, style: textTheme.bodyLarge),
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

// --- helpers (unchanged) ---
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
