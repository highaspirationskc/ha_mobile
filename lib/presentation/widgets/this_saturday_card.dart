import 'package:flutter/material.dart';
import '../../business/events/entities/event.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/session.dart';
import '../../core/routes.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/brand_colors.dart';

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

  void _onServiceChange() {
    _loadState();
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
    final e = widget.event;

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
              // Left side - Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "This Saturday" label
                    Text(
                      'This Saturday',
                      style: t.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

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
                          formatShortDate(e.dateTime),
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
                            e.location,
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action button
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: !_registered
                            ? (_registering ? null : _onRegister)
                            : (!_checkedIn ? _onCheckIn : null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2C3E5C),
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
                            : Text(
                                !_registered
                                    ? 'Register'
                                    : (!_checkedIn ? 'Check-in' : 'Checked in'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right side - Image with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 140,
                      child: _EventImage(src: e.image),
                    ),
                  ),
                  // Registered badge overlay
                  if (_registered)
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
                            color: Colors.white,
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
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: Color(0xFF2C3E5C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Registered',
                                style: t.labelSmall?.copyWith(
                                  color: const Color(0xFF2C3E5C),
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
      color: Colors.white.withOpacity(0.1),
      alignment: Alignment.center,
      child: Icon(Icons.image, color: Colors.white.withOpacity(0.5), size: 32),
    );

    if (src.trim().isEmpty) return placeholder();

    final isNetwork = src.startsWith('http');
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
