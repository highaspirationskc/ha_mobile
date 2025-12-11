import 'package:flutter/material.dart';
import '../../business/user/entities/user_base.dart';
import '../../core/session.dart';
import '../../data/services/api_service.dart';
import 'widgets/mentee_list_items.dart';

class MenteeSection extends StatefulWidget {
  const MenteeSection({super.key});

  @override
  State<MenteeSection> createState() => _MenteeSectionState();
}

class _MenteeSectionState extends State<MenteeSection> {
  List<User> _mentees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    try {
      final mentorId = currentUserId;
      final mentees = await ApiService.instance.getMenteesByMentor(
        mentorId: mentorId,
      );
      if (mounted) {
        setState(() {
          _mentees = mentees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
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
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_mentees.isEmpty) {
      return const SizedBox.shrink();
    }

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
            itemCount: _mentees.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final mentee = _mentees[index];
              return MenteeListItem(
                firstName: mentee.firstName,
                lastName: mentee.lastName,
                image: mentee.image,
                colorIndex: mentee.colorIndex,
                points: 0, // TODO: Fetch points from leaderboard/eventLogs
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
