import 'package:flutter/material.dart';
import '../../../business/scoops/entities/scoop.dart';
import '../../../data/mock/mock_data.dart';
import '../../../core/routes.dart';
import '../../widgets/list_tile_scoop.dart';

class SaturdayScoopSection extends StatelessWidget {
  const SaturdayScoopSection({super.key});

  /// Find the Saturday scoop for the current week
  /// (posted within the last 7 days)
  Scoop? _getThisWeeksSaturdayScoop(List<Scoop> scoops) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Find scoops posted in the last 7 days
    final recentScoops = scoops.where((scoop) {
      return scoop.datePosted.isAfter(weekAgo) &&
          scoop.datePosted.isBefore(now.add(const Duration(days: 1)));
    }).toList();

    if (recentScoops.isEmpty) return null;

    // Sort by date and return the most recent one
    recentScoops.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return recentScoops.first;
  }

  @override
  Widget build(BuildContext context) {
    final scoop = _getThisWeeksSaturdayScoop(mockScoops);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // If no Saturday scoop for this week, return empty widget
    if (scoop == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saturday Scoop',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ListTileScoop(
          scoop: scoop,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.scoopDetail, arguments: scoop);
          },
        ),
      ],
    );
  }
}
