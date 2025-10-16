import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  void setMode(ThemeMode m) {
    if (_mode == m) return;
    _mode = m;
    notifyListeners();
  }
}

/// InheritedNotifier wrapper so you can access ThemeController anywhere.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;

  /// Non-listening read (no rebuilds)
  static ThemeController read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<ThemeScope>()!.widget
              as ThemeScope)
          .notifier!;
}
