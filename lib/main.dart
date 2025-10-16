import 'package:flutter/material.dart';
import 'app.dart';
import 'core/theme/theme_controller.dart';

void main() {
  final themeController = ThemeController();
  runApp(ThemeScope(controller: themeController, child: const HAApp()));
}
