import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class CommunityServiceTile extends StatelessWidget {
  final double totalHours;
  final int totalEvents;

  const CommunityServiceTile({
    super.key,
    required this.totalHours,
    required this.totalEvents,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.communityService);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Community Service Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.groups, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            // Community Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Service',
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalHours.toStringAsFixed(totalHours == totalHours.roundToDouble() ? 0 : 1)} hrs · $totalEvents events',
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
          ],
        ),
      ),
    );
  }
}
