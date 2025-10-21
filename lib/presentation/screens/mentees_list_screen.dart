// lib/presentation/screens/mentees_list_screen.dart
import 'package:flutter/material.dart';

class MenteesListScreen extends StatelessWidget {
  const MenteesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 12, // placeholder list
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: cs.surfaceVariant.withOpacity(0.25),
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text('Mentee #${i + 1}', style: t.titleMedium),
          subtitle: const Text('Tap to view details (coming soon)'),
          onTap: () {
            // TODO: mentee detail
          },
        );
      },
    );
  }
}
