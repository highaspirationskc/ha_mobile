import 'package:flutter/material.dart';
import 'package:ha_mobile/core/theme/brand_colors.dart';

class HATabs extends StatelessWidget {
  final TabController controller;
  final List<String> tabNames;

  const HATabs({super.key, required this.controller, required this.tabNames});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kHAPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tabNames.length, (index) {
                final isSelected = controller.index == index;
                return GestureDetector(
                  onTap: () => controller.animateTo(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kHAPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tabNames[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? Colors.white : kHAPrimary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
