import 'package:flutter/material.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/routes.dart';
import '../../presentation/widgets/card_event.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: OlympicSeasonService.instance,
      builder: (context, _) {
        final upcomingEvents = OlympicSeasonService.instance
            .getUpcomingEvents();
        final displayEvents = upcomingEvents.take(10).toList();
        final hasMore = upcomingEvents.length > 10;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with View All button
            Row(
              children: [
                Text(
                  'Upcoming Events',
                  style: textTheme.titleSmall?.copyWith(
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

            // Horizontal scrolling event cards
            SizedBox(
              height: 200,
              child: displayEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming events',
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      itemCount: displayEvents.length + (hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        // Show event cards
                        if (i < displayEvents.length) {
                          final e = displayEvents[i];
                          return SizedBox(
                            width: 300,
                            child: EventCard(
                              event: e,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.eventDetail,
                                  arguments: e,
                                );
                              },
                            ),
                          );
                        }

                        // Show "View More" card at the end (only if hasMore)
                        return _ViewMoreCard(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.calendar);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
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
      // borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
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
