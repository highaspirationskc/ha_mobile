import 'package:flutter/material.dart';
import 'package:ha_mobile/core/routes.dart';

import '../../data/mock/mock_data.dart';
import '../widgets/card_event.dart';
import '../widgets/list_tile_scoop.dart';
import '../widgets/this_saturday_card.dart';
import '../widgets/bottom_sheet_community_service.dart';
import '../widgets/bottom_sheet_pulse.dart';
import '../../business/events/entities/event.dart';
import '../../core/theme/brand_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final saturdayEvent = _getNextSaturdayEvent(mockEvents);
    final upcomingEvents = saturdayEvent != null
        ? mockEvents.where((e) => e.id != saturdayEvent.id).toList()
        : mockEvents;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ----- This Saturday Card -----
        if (saturdayEvent != null) ...[
          ThisSaturdayCard(
            event: saturdayEvent,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.eventDetail, arguments: saturdayEvent);
            },
          ),
          const SizedBox(height: 24),
        ],

        // ----- Add Section -----
        Text(
          'Add',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _AddButton(
                icon: Icons.volunteer_activism_outlined,
                label: 'Community Service',
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    kBrandSeed, // Purple at bottom
                    kBrandPurpleLight, // Lighter purple at top
                  ],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (context) => const BottomSheetCommunityService(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AddButton(
                icon: Icons.favorite_outline,
                label: 'Check-In',
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    kBrandAqua, // Aqua at bottom
                    kBrandAquaLight, // Lighter aqua at top
                  ],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (context) => const BottomSheetPulse(),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

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
            itemCount: upcomingEvents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final e = upcomingEvents[i];
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

class _AddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _AddButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Icon in top right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                ),
                // Label at bottom left
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 40,
                  child: Text(
                    label,
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
