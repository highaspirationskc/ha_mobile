// lib/presentation/screens/check_in_scanner.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/session.dart'; // <-- shared user id
import '../../core/utils/date_formatters.dart';
import '../../data/mock/mock_data.dart';
import '../../data/services/api_service.dart';
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

  Event? _eventFromPayload(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // deep link: ha://checkin?eventId=evt_3
    if (s.contains('eventId=')) {
      final uri = Uri.tryParse(s);
      final id = uri?.queryParameters['eventId'];
      if (id != null) {
        try {
          return mockEvents.firstWhere((e) => e.id == id);
        } catch (_) {}
      }
    }

    // plain id: evt_3
    try {
      return mockEvents.firstWhere((e) => e.id == s);
    } catch (_) {}
    return null;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    final evt = _eventFromPayload(raw);
    if (evt == null) {
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

    await _openConfirm(evt);
  }

  Future<void> _openConfirm(Event evt) async {
    setState(() => _handling = true);
    _controller.stop();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ConfirmSheet(event: evt),
    );

    if (!mounted) return;

    if (ok == true) {
      Navigator.of(context).pop(true); // close scanner with success
    } else {
      setState(() => _handling = false);
      _controller.start();
    }
  }

  // Mock scan button (useful on web/simulator)
  Future<void> _mockScan() async {
    final id =
        widget.mockEventId ??
        (mockEvents.isNotEmpty ? mockEvents.first.id : null);
    if (id == null) return;
    final evt =
        _eventFromPayload(id) ??
        mockEvents.firstWhere(
          (e) => e.id == id,
          orElse: () => mockEvents.first,
        );
    await _openConfirm(evt);
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
              onPressed: _handling ? null : _mockScan,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Mock scan'),
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
  final Event event;
  const _ConfirmSheet({required this.event});

  @override
  State<_ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<_ConfirmSheet> {
  bool _submitting = false;

  Future<void> _complete() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      // 1) Ensure the user is registered (handles stale/race conditions)
      final isReg = await ApiService.instance.isRegistered(
        eventId: widget.event.id,
        userId: kCurrentUserId,
      );
      if (!isReg) {
        await ApiService.instance.registerForEvent(
          eventId: widget.event.id,
          userId: kCurrentUserId,
        );
      }

      // 2) Perform check-in
      await ApiService.instance.checkInForEvent(
        eventId: widget.event.id,
        userId: kCurrentUserId,
      );

      if (!mounted) return;

      // 3) Notify listeners and close with success
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
    final e = widget.event;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image on top
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _SheetImage(src: e.image),
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
                      '${formatLongDate(e.dateTime)}  •  ${formatTime(e.dateTime)}',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
