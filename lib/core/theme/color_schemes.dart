import 'package:flutter/material.dart';
import 'brand_colors.dart';

ColorScheme buildLightScheme({Color seed = kHAPrimary}) {
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  // Create a darker version of the primary color
  final darkerPrimary = base.primary.withOpacity(0.12);

  return base.copyWith(
    surface: kBgLight, // use surface instead of background
    surfaceContainerHighest:
        darkerPrimary, // Custom color for team screen background
  );
}

ColorScheme buildDarkScheme({Color seed = kHAPrimary}) {
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );

  // Create a darker version of the primary color for dark theme
  final darkerPrimary = base.primary.withOpacity(0.15);

  return base.copyWith(
    surface: kBgDark, // use surface instead of background
    surfaceContainerHighest:
        darkerPrimary, // Custom color for team screen background
  );
}

const List<Color> kProfileColors = <Color>[
  Color(0xFFEF4444), // red
  Color(0xFFF97316), // orange
  Color(0xFFF59E0B), // amber
  Color(0xFF10B981), // emerald
  Color(0xFF22C55E), // green
  Color(0xFF06B6D4), // cyan
  Color(0xFF0EA5E9), // sky
  Color(0xFF3B82F6), // blue
  Color(0xFF6366F1), // indigo
  Color(0xFFA855F7), // purple
  Color(0xFFEC4899), // pink
  Color(0xFF14B8A6), // teal
];
