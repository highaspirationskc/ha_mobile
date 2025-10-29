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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999), // Fully rounded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Material(
            color: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  indicatorColor: Colors.transparent,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    return const TextStyle(fontSize: 0);
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: index,
                backgroundColor: Colors.transparent,
                elevation: 0,
                onDestinationSelected: onChanged,
                destinations: [
                  for (final t in tabs)
                    NavigationDestination(
                      icon: t.$1,
                      selectedIcon: t.$2,
                      label: '',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
