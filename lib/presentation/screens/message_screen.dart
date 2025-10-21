import 'package:flutter/material.dart';
import '../../business/messages/entities/message.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../data/mock/mock_messages.dart';
import '../../core/session.dart';
import '../widgets/chit.dart';

class MessageScreen extends StatelessWidget {
  final String? messageId;
  const MessageScreen({super.key, this.messageId});

  @override
  Widget build(BuildContext context) {
    final message = _findMessageById(messageId);
    if (message == null) {
      return Center(child: Text('Message not found'));
    }

    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: cs.background,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author header with avatar, name, mentor chip, and timestamp
                _buildAuthorHeader(context, message, cs, t),

                const SizedBox(height: 24),

                // Message subject
                Text(
                  message.subject,
                  style: t.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Message body
                Text(
                  message.message,
                  style: t.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(
    BuildContext context,
    Message message,
    ColorScheme cs,
    TextTheme t,
  ) {
    final author = message.author;
    final authorName = _getAuthorName(author);
    final showMentorChip = _isFromMyMentor(author);
    final relativeTime = _getRelativeTime(
      message.updatedAt ?? message.createdAt,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author avatar
        SizedBox(width: 40, height: 40, child: _AuthorAvatar(user: author)),

        const SizedBox(width: 12),

        // Author name and mentor chip
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    authorName,
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (showMentorChip) ...[
                    const SizedBox(width: 8),
                    const Chit(label: 'mentor'),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Timestamp
        Text(
          relativeTime,
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  String _getAuthorName(User user) {
    final firstName = user.firstName?.trim() ?? '';
    final lastName = user.lastName?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? user.email : fullName;
  }

  bool _isFromMyMentor(User author) {
    return currentUserKind.value == CurrentUserKind.mentee &&
        author.roles.contains(UserRole.mentor);
  }

  String _getRelativeTime(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo';
    final years = (diff.inDays / 365).floor();
    return '${years}y';
  }

  Message? _findMessageById(String? id) {
    if (id == null) return null;
    try {
      return mockMessages.firstWhere((message) => message.id == id);
    } catch (e) {
      return null;
    }
  }
}

class _AuthorAvatar extends StatelessWidget {
  final User user;
  const _AuthorAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final img = user.image ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (img.isNotEmpty)
            Image(
              image: img.startsWith('http')
                  ? NetworkImage(img) as ImageProvider
                  : AssetImage(img),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackInitials(context),
            )
          else
            _fallbackInitials(context),

          // White border like in the message tile
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackInitials(BuildContext context) {
    final f = (user.firstName ?? '').trim();
    final l = (user.lastName ?? '').trim();
    final initials =
        (f.isNotEmpty ? f.characters.first : '') +
        (l.isNotEmpty ? l.characters.first : '');

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        (initials.isEmpty ? 'U' : initials).toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
