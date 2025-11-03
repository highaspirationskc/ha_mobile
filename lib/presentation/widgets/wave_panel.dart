import 'package:flutter/material.dart';

/// A panel with a smooth single wave across it (non-animated).
/// The wave is drawn using bezier curves so it scales to any width/height.
///
/// Usage:
/// WavePanel(
///   height: 320,
///   color: Theme.of(context).colorScheme.surface,
///   borderRadius: 24,
///   heightFactor: 0.66, // wave vertical position (0..1)
///   amplitude: 28,      // wave hump height in logical px
///   child: ...          // content below the wave (optional)
/// )
class WavePanel extends StatelessWidget {
  final double height;
  final double borderRadius;
  final double heightFactor; // 0..1: where the wave runs vertically
  final double amplitude; // how tall the wave hump is
  final Color? color;
  final Widget? child;
  final bool
  paintBottom; // if true, paints below wave; if false, paints above wave

  const WavePanel({
    super.key,
    required this.height,
    this.borderRadius = 24,
    this.heightFactor = 0.66,
    this.amplitude = 28,
    this.color,
    this.child,
    this.paintBottom = false, // default paints top (original behavior)
  }) : assert(heightFactor > 0 && heightFactor < 1);

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _WaveFillPainter(
          color: bg,
          heightFactor: heightFactor,
          amplitude: amplitude,
          paintBottom: paintBottom,
        ),
        child: SizedBox(width: double.infinity, height: height, child: child),
      ),
    );
  }
}

/// Paints a panel with a wavy edge
class _WaveFillPainter extends CustomPainter {
  final Color color;
  final double heightFactor;
  final double amplitude;
  final bool paintBottom;

  _WaveFillPainter({
    required this.color,
    required this.heightFactor,
    required this.amplitude,
    required this.paintBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate the baseline height for the wave
    final h = size.height * heightFactor;
    final a = amplitude.clamp(0.0, size.height);

    final Path path;

    if (paintBottom) {
      // Create a path that fills BELOW the wave (from wave to bottom)
      path = Path()
        ..moveTo(0, h) // Start at wave on left
        // First wave curve (goes down)
        ..quadraticBezierTo(size.width * 0.25, h + a, size.width * 0.5, h)
        // Second wave curve (goes up)
        ..quadraticBezierTo(size.width * 0.75, h - a, size.width, h)
        ..lineTo(size.width, size.height) // Go down to bottom-right
        ..lineTo(0, size.height) // Go across to bottom-left
        ..close(); // Close back to start
    } else {
      // Create a path that fills ABOVE the wave (from top to wave) - original behavior
      path = Path()
        ..moveTo(0, 0) // Start at top-left
        ..lineTo(0, h) // Go down to wave start on left
        // First wave curve (goes down)
        ..quadraticBezierTo(size.width * 0.25, h + a, size.width * 0.5, h)
        // Second wave curve (goes up)
        ..quadraticBezierTo(size.width * 0.75, h - a, size.width, h)
        ..lineTo(size.width, 0) // Go up to top-right
        ..close(); // Close back to top-left
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveFillPainter old) =>
      old.color != color ||
      old.heightFactor != heightFactor ||
      old.amplitude != amplitude ||
      old.paintBottom != paintBottom;
}
