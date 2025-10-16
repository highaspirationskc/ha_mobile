import 'package:flutter/material.dart';

/// Reusable bottom navigation bar used by the shell.
///
/// Pass in the current tab index, a callback to change tabs,
/// and a list of (icon, selectedIcon, label) for each tab.
class HANavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<(Widget icon, Widget selectedIcon, String label)> tabs;

  const HANavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onChanged,
      destinations: [
        for (final t in tabs)
          NavigationDestination(
            icon: t.$1,
            selectedIcon: t.$2,
            label: t.$3,
          ),
      ],
    );
  }
}
