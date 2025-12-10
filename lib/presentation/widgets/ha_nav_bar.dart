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
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Container(
        height: 60,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => onChanged(i),
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        height: 60,
                        child: Center(
                          child: i == index ? tabs[i].$2 : tabs[i].$1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
