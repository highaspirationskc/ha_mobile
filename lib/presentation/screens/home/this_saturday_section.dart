import 'package:flutter/material.dart';
import '../../../business/events/entities/event.dart';
import '../../../data/mock/mock_data.dart';
import '../../../core/routes.dart';
import '../../widgets/this_saturday_card.dart';

class ThisSaturdaySection extends StatelessWidget {
  const ThisSaturdaySection({super.key});

  /// Find the next Saturday event
  Event? _getNextSaturdayEvent(List<Event> events) {
    final now = DateTime.now();
    final saturdayEvents = events.where((e) {
      return e.dateTime.isAfter(now) && e.dateTime.weekday == DateTime.saturday;
    }).toList();

    if (saturdayEvents.isEmpty) return null;

    // Sort by date and return the nearest one
    saturdayEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return saturdayEvents.first;
  }

  @override
  Widget build(BuildContext context) {
    final saturdayEvent = _getNextSaturdayEvent(mockEvents);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
  }
}
