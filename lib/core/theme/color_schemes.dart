// lib/core/theme/color_schemes.dart
import 'package:flutter/material.dart';
import 'brand_colors.dart';

/// Build a ColorScheme from a seed (Material 3).
ColorScheme buildLightScheme({Color seed = kBrandSeed}) =>
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

ColorScheme buildDarkScheme({Color seed = kBrandSeed}) =>
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

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

/// If later you want full manual control, you can provide fixed schemes here:
// const ColorScheme kLightScheme = ColorScheme(
//   brightness: Brightness.light,
//   primary: Color(0xFF4F46E5),
//   onPrimary: Colors.white,
//   secondary: Color(0xFF10B981),
//   onSecondary: Colors.white,
//   tertiary: Color(0xFFEC4899),
//   onTertiary: Colors.white,
//   error: Color(0xFFBA1A1A),
//   onError: Colors.white,
//   background: Color(0xFFFFFBFF),
//   onBackground: Color(0xFF1B1B1F),
//   surface: Color(0xFFFFFBFF),
//   onSurface: Color(0xFF1B1B1F),
//   surfaceVariant: Color(0xFFE3E1EC),
//   onSurfaceVariant: Color(0xFF46464F),
//   outline: Color(0xFF777680),
//   shadow: Colors.black,
//   outlineVariant: Color(0xFFC7C5D0),
//   scrim: Colors.black,
//   primaryContainer: Color(0xFFE0E7FF),
//   onPrimaryContainer: Color(0xFF1A237E),
//   secondaryContainer: Color(0xFFD1FAE5),
//   onSecondaryContainer: Color(0xFF064E3B),
//   tertiaryContainer: Color(0xFFFCE7F3),
//   onTertiaryContainer: Color(0xFF831843),
// );
