import 'package:flutter/material.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/routes.dart';
import '../../presentation/widgets/this_saturday_card.dart';

class ThisSaturdaySection extends StatelessWidget {
  const ThisSaturdaySection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: OlympicSeasonService.instance,
      builder: (context, _) {
        final saturdayEvent = OlympicSeasonService.instance
            .getNextSaturdayEvent();

        // If no Saturday event, return empty widget
        if (saturdayEvent == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Saturday',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ThisSaturdayCard(
              event: saturdayEvent,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.eventDetail, arguments: saturdayEvent);
              },
            ),
          ],
        );
      },
    );
  }
}
