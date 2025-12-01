import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  final themeController = ThemeController();
  runApp(ThemeScope(controller: themeController, child: const HAApp()));
}
