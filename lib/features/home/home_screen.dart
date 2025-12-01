import 'package:flutter/material.dart';
import '../../core/session.dart';
import 'mentee_spotlight_section.dart';
import 'this_saturday_section.dart';
import 'saturday_scoop_section.dart';
import 'add_section.dart';
import 'mentee_section.dart';
import 'upcoming_events.dart';
import 'past_scoops_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrentUserKind>(
      valueListenable: currentUserKind,
      builder: (context, kind, _) {
        final isMentor = kind == CurrentUserKind.mentor;
        final isMentee = kind == CurrentUserKind.mentee;

        return ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100, // Space for floating nav bar
          ),
          children: [
            // ----- Mentee Spotlight -----
            const MenteeSpotlightSection(),
            const SizedBox(height: 24),

            // ----- This Saturday Card -----
            const ThisSaturdaySection(),
            const SizedBox(height: 24),

            // ----- Saturday Scoop -----
            const SaturdayScoopSection(),
            const SizedBox(height: 24),

            // ----- Add Section (Mentees only) or Eyes On Section (Mentors only) -----
            // Volunteers and Parents see neither section
            if (isMentor)
              const MenteeSection()
            else if (isMentee)
              const AddSection(),
            if (isMentor || isMentee) const SizedBox(height: 24),

            // ----- Upcoming Events -----
            const UpcomingEventsSection(),
            const SizedBox(height: 24),

            // ----- Saturday Scoops -----
            const PastScoopsSection(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
