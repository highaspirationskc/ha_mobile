import 'package:flutter/material.dart';
import '../../../core/routes.dart';
import '../../data/mock/mock_messages.dart';
import '../../business/messages/entities/message.dart';
import '../widgets/list_tile_message.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort messages newest to oldest
    final sortedMessages = List<Message>.from(mockMessages)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Group messages by time period
    final groupedMessages = _groupMessagesByTime(sortedMessages);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _getTotalItemCount(groupedMessages),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildItem(context, index, groupedMessages);
      },
    );
  }

  Map<String, List<Message>> _groupMessagesByTime(List<Message> messages) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    final Map<String, List<Message>> groups = {
      'Today': [],
      'Yesterday': [],
      'Last Week': [],
      'Older': [],
    };

    for (final message in messages) {
      final messageDate = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (messageDate.isAtSameMomentAs(today)) {
        groups['Today']!.add(message);
      } else if (messageDate.isAtSameMomentAs(yesterday)) {
        groups['Yesterday']!.add(message);
      } else if (messageDate.isAfter(lastWeek)) {
        groups['Last Week']!.add(message);
      } else {
        groups['Older']!.add(message);
      }
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  int _getTotalItemCount(Map<String, List<Message>> groupedMessages) {
    int count = 0;
    for (final group in groupedMessages.values) {
      count += group.length + 1; // +1 for section header
    }
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Map<String, List<Message>> groupedMessages,
  ) {
    int currentIndex = 0;

    for (final entry in groupedMessages.entries) {
      final groupName = entry.key;
      final messages = entry.value;

      // Add section header
      if (index == currentIndex) {
        return _buildSectionHeader(context, groupName);
      }
      currentIndex++;

      // Add messages in this group
      for (int i = 0; i < messages.length; i++) {
        if (index == currentIndex) {
          return ListTileMessage(
            message: messages[i],
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.notificationMessage,
                arguments: messages[i].id,
              );
            },
          );
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
