// lib/features/mentees/mentees_list_screen.dart
import 'package:flutter/material.dart';
import '../../business/user/entities/user.dart';
import '../../core/session.dart';
import '../../data/services/api_service.dart';
import 'widgets/mentee_call_tile.dart';
import 'mentee_screen.dart';

class MenteesListScreen extends StatefulWidget {
  const MenteesListScreen({super.key});

  @override
  State<MenteesListScreen> createState() => _MenteesListScreenState();
}

class _MenteesListScreenState extends State<MenteesListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<User> _mentees = [];

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the current mentor's ID
      final mentorId = currentUserId;

      // Fetch mentees for this mentor
      final mentees = await ApiService.instance.getMenteesByMentor(
        mentorId: mentorId,
      );

      setState(() {
        _mentees = mentees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load mentees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: t.bodyLarge?.copyWith(color: cs.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadMentees,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_mentees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'No mentees assigned yet',
              style: t.titleLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Mentees will appear here once they are assigned to you',
              style: t.bodyMedium?.copyWith(color: cs.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMentees,
      child: ListView.separated(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 100, // Space for floating nav bar
        ),
        itemCount: _mentees.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 1,
          indent: 72, // Align with text (avatar width + spacing)
          color: cs.outlineVariant.withOpacity(0.3),
        ),
        itemBuilder: (_, i) {
          final mentee = _mentees[i];
          return MenteeCallTile(
            mentee: mentee,
            onTap: () {
              // Navigate to mentee detail screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MenteeScreen(mentee: mentee),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
