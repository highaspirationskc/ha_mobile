import 'package:flutter/material.dart';
import 'package:ha_mobile/presentation/screens/root_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/color_schemes.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/screens/login_screen.dart';

class HAApp extends StatelessWidget {
  const HAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context); // listens for changes
    final light = buildTheme(buildLightScheme());
    final dark = buildTheme(buildDarkScheme());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'High Aspirations',
      theme: light,
      darkTheme: dark,
      themeMode: controller.mode, // <- live mode from controller
      home: const RootShell(),
      // home: const LoginScreen(),
    );
  }
}
