import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/routes.dart';
import '../../data/services/api_service.dart';
import '../../business/messages/entities/message.dart';
import '../widgets/list_tile_message.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Message> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Force refresh when navigating to notifications screen to get latest messages
    _loadMessages(forceRefresh: true);
    ApiService.instance.changes.addListener(_onApiChange);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChange);
    super.dispose();
  }

  void _onApiChange() {
    // Refresh messages from cache when API changes (e.g., message marked as read)
    _refreshFromCache();
  }

  void _refreshFromCache() {
    // Get the latest cached inbox without forcing a network request
    final cachedMessages = ApiService.instance.getInbox();
    cachedMessages.then((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    });
  }

  Future<void> _loadMessages({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messages = await ApiService.instance.getInbox(
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Container(
        color: cs.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        color: cs.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading messages',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadMessages, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final groupedMessages = _groupMessagesByTime(_messages);

    return Container(
      color: cs.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () => _loadMessages(forceRefresh: true),
            builder: (context, mode, pulledExtent, triggerDistance, indicatorExtent) {
              final opacity = (pulledExtent / triggerDistance).clamp(0.0, 1.0);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_messages.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildItem(context, index, groupedMessages),
                  childCount: _getTotalItemCount(groupedMessages),
                ),
              ),
            ),
        ],
      ),
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
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
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
