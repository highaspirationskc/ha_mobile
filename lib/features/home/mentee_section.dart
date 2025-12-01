import 'package:flutter/material.dart';
import '../../data/mock/mock_leaderboard.dart';
import 'widgets/mentee_list_items.dart';

class MenteeSection extends StatelessWidget {
  const MenteeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Get the 10 mentees with lowest points (for "Eyes On" - mentees who need attention)
    final menteesWithPoints = mockMenteeRankings
        .map(
          (ranking) => {
            'firstName': ranking.mentee.firstName,
            'lastName': ranking.mentee.lastName,
            'image': ranking.mentee.image,
            'colorIndex': ranking.mentee.colorIndex,
            'points': ranking.points,
            'id': ranking.mentee.id,
          },
        )
        .toList();

    // Sort by points ascending (lowest first) and take first 10
    menteesWithPoints.sort(
      (a, b) => (a['points'] as int).compareTo(b['points'] as int),
    );
    final eyesOnMentees = menteesWithPoints.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eyes On',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: eyesOnMentees.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final mentee = eyesOnMentees[index];
              return MenteeListItem(
                firstName: mentee['firstName'] as String?,
                lastName: mentee['lastName'] as String?,
                image: mentee['image'] as String?,
                colorIndex: mentee['colorIndex'] as int?,
                points: mentee['points'] as int,
                onTap: () {
                  // TODO: Navigate to mentee detail screen
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
