import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        // soft shadow from the top edge of the bar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, -4), // negative Y => shadow above
          ),
        ],
      ),
      child: Material(
        color: cs.surface,
        surfaceTintColor: Colors
            .transparent, // avoid the Material3 tint washing out your surface
        child: NavigationBar(
          selectedIndex: index,
          backgroundColor: Colors
              .transparent, // use the Material color above, keep this transparent
          elevation: 0, // shadow handled by the BoxShadow above
          onDestinationSelected: onChanged,
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: t.$1,
                selectedIcon: t.$2,
                label: t.$3,
              ),
          ],
        ),
      ),
    );
  }
}
