import 'package:flutter/material.dart';
import 'package:ha_mobile/core/routes.dart';

import '../../data/mock/mock_data.dart';
import '../widgets/card_event.dart';
import '../widgets/list_tile_scoop.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ----- Upcoming Events -----
        Row(
          children: [
            Text(
              'Upcoming Events',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.calendar);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: mockEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final e = mockEvents[i];
              return SizedBox(
                width: 300,
                child: EventCard(
                  event: e,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.eventDetail, arguments: e);
                  },
                ),
              );
            },
          ),
        ),

        // Spacer / divider between sections
        const SizedBox(height: 24),
        // Divider(height: 1, thickness: 1, color: cs.outlineVariant),
        const SizedBox(height: 16),

        // ----- Saturday Scoops -----
        Row(
          children: [
            Text(
              'Saturday Scoops',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            // Optional: a "View All" or filter action could go here later.
          ],
        ),
        const SizedBox(height: 12),

        // Scoops list (non-scrollable; lets parent ListView scroll)
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockScoops.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = mockScoops[i];
            return ListTileScoop(
              scoop: s,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.scoopDetail, arguments: s);
              },
            );
          },
        ),
      ],
    );
  }
}
