import 'package:flutter/material.dart';
import '../../data/mock/mock_data.dart';
import '../../core/routes.dart';
import '../../presentation/widgets/saturday_scoop_small.dart';

class PastScoopsSection extends StatelessWidget {
  const PastScoopsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All button
        Row(
          children: [
            Text(
              'Past Scoops',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.pastScoops);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling scoop cards
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: (mockScoops.length > 10 ? 10 : mockScoops.length) + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              // Show up to 10 scoop cards
              if (i < 10 && i < mockScoops.length) {
                final scoop = mockScoops[i];
                return SizedBox(
                  width: 105,
                  child: SaturdayScoopSmall(
                    scoop: scoop,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.scoopDetail, arguments: scoop);
                    },
                  ),
                );
              }

              // Show "View More" card at the end
              return _ViewMoreCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.pastScoops);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ViewMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View More',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
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
