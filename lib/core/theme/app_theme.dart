// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'brand_colors.dart';

ThemeData buildTheme(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final defaultTextColor = isDark ? kFontLight : kFontDark;

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,

    // Pages/surfaces now come from surface
    scaffoldBackgroundColor: scheme.surface,
    canvasColor: scheme.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: defaultTextColor,
      elevation: 0,
    ),
    cardColor: scheme.surface,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: defaultTextColor,
      displayColor: defaultTextColor,
    ),
    iconTheme: IconThemeData(color: defaultTextColor),
    listTileTheme: ListTileThemeData(
      textColor: defaultTextColor,
      iconColor: defaultTextColor,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      hintStyle: TextStyle(color: defaultTextColor.withOpacity(0.60)),
    ),
  );
}
