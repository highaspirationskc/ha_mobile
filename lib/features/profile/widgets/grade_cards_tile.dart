import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class GradeCardsTile extends StatelessWidget {
  final int totalCards;

  const GradeCardsTile({super.key, required this.totalCards});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.gradeCards);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Grade Cards Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.school_outlined, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            // Grade Cards Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade Cards',
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalCards ${totalCards == 1 ? 'card' : 'cards'}',
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
