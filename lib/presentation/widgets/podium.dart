import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

class Podium extends StatelessWidget {
  final Color baseColor;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final int rank;

  const Podium({
    super.key,
    required this.baseColor,
    required this.rank,
    this.height = 120,
    this.width = 100,
    this.borderRadius = const BorderRadius.vertical(
      top: Radius.circular(6),
      bottom: Radius.circular(6),
    ),
  });

  @override
  Widget build(BuildContext context) {
    // We'll make the "top" about 12px tall.
    const double topHeight = 12;

    // A lighter version of baseColor for the top.
    final Color topColor = _lighten(baseColor, 0.35);

    // We'll also add a subtle front gradient so it's not flat.
    final Color frontTop = _lighten(baseColor, 0.15);
    final Color frontBottom = _darken(baseColor, 0.25);

    // Adjust height based on rank
    final double adjustedHeight = rank == 1
        ? height
        : rank == 2
        ? height * 2 / 3
        : height / 3;

    return SizedBox(
      width: width,
      height: adjustedHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // FRONT FACE
          Positioned.fill(
            top: topHeight, // Start where the top face ends
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [frontTop, frontBottom],
                ),
              ),
            ),
          ),

          // TOP FACE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight,
            child: CustomPaint(
              painter: _TopFacePainter(color: topColor, rank: rank),
            ),
          ),

          // WREATH with number for rank 1
          if (rank == 1)
            Positioned(
              top: topHeight + 24, // 24px from top of front edge
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/wreath.svg',
                      width: 120,
                      height: 120,
                    ),
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Number for rank 2
          if (rank == 2)
            Positioned(
              top: topHeight + 24, // 24px from top of front edge
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Number for rank 3
          if (rank == 3)
            Positioned(
              top: topHeight + 24, // 24px from top of front edge
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- color helpers ---

  Color _lighten(Color c, double amount) {
    // amount: 0 -> no change, 1 -> white
    final hsl = HSLColor.fromColor(c);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  Color _darken(Color c, double amount) {
    // amount: 0 -> no change, 1 -> black
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

/// Paints the trapezoid "top" of the podium.
/// Visually it's like:
///
///      /--------\    <-- lighter color
///     |          |
///
/// We fake perspective by pulling the left/right corners inward.
class _TopFacePainter extends CustomPainter {
  final Color color;
  final int rank;

  _TopFacePainter({required this.color, required this.rank});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // How much to "skew" the sides inward.
    // We'll base this on width so it scales.
    final double inset = math.max(4, size.width * 0.07);

    // We'll round the outer edge slightly with a quadratic curve.
    final double radius = 4;

    // Adjust vertices based on rank
    // Rank 2: shift top-left 20px to the right, top-right vertical (no inset)
    // Rank 3: top-left vertical (no inset), shift top-right 20px to the left
    final double leftTopX = rank == 2
        ? inset + 20
        : rank == 3
        ? 0 // Vertical edge for rank 3
        : inset;
    final double rightTopX = rank == 2
        ? size
              .width // Vertical edge for rank 2
        : rank == 3
        ? size.width - inset - 20
        : size.width - inset;

    final path = Path()
      // start bottom-left
      ..moveTo(0, size.height)
      // go to bottom-right
      ..lineTo(size.width, size.height)
      // go to top-right, but inset inwards (adjusted for rank 3)
      ..lineTo(rightTopX, 0)
      // curve across the top toward top-left+inset (adjusted for rank 2)
      ..quadraticBezierTo(
        size.width / 2,
        -radius, // slight upward bow to mimic that pill-y arc
        leftTopX,
        0,
      )
      // back down to bottom-left
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopFacePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rank != rank;
  }
}
