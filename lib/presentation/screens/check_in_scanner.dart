// lib/presentation/screens/check_in_scanner.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/session.dart';
import '../../core/utils/date_formatters.dart';
import '../../data/services/api_service.dart';
import '../../data/services/olympic_season_service.dart';
import '../../business/events/entities/event.dart';
import '../widgets/button_long.dart';
import '../widgets/button_long_outlined.dart';

class CheckInScannerScreen extends StatefulWidget {
  /// Optional: event id to use for the mock button (handy when invoked from a specific event)
  final String? mockEventId;
  const CheckInScannerScreen({super.key, this.mockEventId});

  @override
  State<CheckInScannerScreen> createState() => _CheckInScannerScreenState();
}

class _CheckInScannerScreenState extends State<CheckInScannerScreen> {
  bool _handling = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Extract event ID from QR code payload
  /// Returns null if invalid format
  String? _eventIdFromPayload(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // deep link: ha://checkin?eventId=123
    if (s.contains('eventId=')) {
      final uri = Uri.tryParse(s);
      final id = uri?.queryParameters['eventId'];
      if (id != null && id.isNotEmpty) return id;
    }

    // plain id: 123 or evt_3
    if (s.isNotEmpty) return s;

    return null;
  }

  /// Try to find event in cached data for display (optional)
  Event? _findEvent(String eventId) {
    return OlympicSeasonService.instance.getEventById(eventId);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final eventId = _eventIdFromPayload(raw);
    if (eventId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await _openConfirm(eventId);
  }

  Future<void> _openConfirm(String eventId) async {
    setState(() => _handling = true);
    _controller.stop();

    // Try to find event details in cached data for display
    final event = _findEvent(eventId);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConfirmSheet(eventId: eventId, event: event),
    );

    if (!mounted) return;

    if (ok == true) {
      Navigator.of(context).pop(true); // close scanner with success
    } else {
      setState(() => _handling = false);
      _controller.start();
    }
  }

  // Test scan button (useful on web/simulator)
  Future<void> _testScan() async {
    print('🔍 Test scan triggered');
    print('   mockEventId from widget: ${widget.mockEventId}');

    final events = OlympicSeasonService.instance.events;
    print('   Available events: ${events.length}');

    final id =
        widget.mockEventId ?? (events.isNotEmpty ? events.first.id : null);
    print('   Using event ID: $id');

    if (id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No events available'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    await _openConfirm(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: kIsWeb
                ? const _WebCameraUnavailable()
                : MobileScanner(controller: _controller, onDetect: _onDetect),
          ),

          // Top bar (close)
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Instruction overlay
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 80),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Scan the QR code to check-in',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Mock button
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.extended(
              heroTag: 'mockScan',
              backgroundColor: Colors.white.withOpacity(0.92),
              foregroundColor: Colors.black87,
              onPressed: _handling ? null : _testScan,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Test scan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebCameraUnavailable extends StatelessWidget {
  const _WebCameraUnavailable();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Camera scanning is unavailable in this environment.\nTry a physical device or emulator.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white), // readable contrast
      ),
    );
  }
}

class _ConfirmSheet extends StatefulWidget {
  final String eventId;
  final Event? event; // Optional - for display purposes only
  const _ConfirmSheet({required this.eventId, this.event});

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _submitting = false;

  Future<void> _complete() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      // Perform check-in directly (server handles registration if needed)
      await ApiService.instance.checkInForEvent(
        eventId: widget.eventId,
        userId: currentUserId,
      );

      if (!mounted) return;

      // Notify listeners and close with success
      ApiService.instance.changes.value++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final e = widget.event;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show event details if available, otherwise show simple check-in
          if (e != null) ...[
            // Image on top
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _SheetImage(src: e.imageUrl ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            // Event details below
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${formatLongDate(e.eventDate)}  •  ${formatTime(e.eventDate)}',
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            // Simple check-in confirmation without event details
            Icon(Icons.qr_code_scanner, size: 64, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Ready to Check In',
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Complete to check in to this event',
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 20),
          ButtonLong(
            label: _submitting ? 'Completing…' : 'Complete',
            icon: Icons.check_circle_outline,
            isLoading: _submitting,
            onPressed: _submitting ? null : _complete,
          ),
          const SizedBox(height: 12),
          ButtonLongOutlined(
            label: 'Cancel',
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _SheetImage extends StatelessWidget {
  final String src;
  const _SheetImage({required this.src});

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
