import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: Text('Message #${i + 1}'),
        subtitle: const Text('From: Mentor/Mentee'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Push within the Notifications tab’s own Navigator
          Navigator.of(context).pushNamed(
            AppRoutes.notificationMessage,
            arguments: 'msg-${i + 1}', // optional
          );
        },
      ),
    );
  }
}
