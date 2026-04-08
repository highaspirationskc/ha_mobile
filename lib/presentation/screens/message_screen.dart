import 'package:flutter/material.dart';
import '../../business/messages/entities/message.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/brand_colors.dart';
import '../widgets/chit.dart';

class MessageScreen extends StatefulWidget {
  final String? messageId;
  const MessageScreen({super.key, this.messageId});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  Message? _message;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    if (widget.messageId == null) {
      setState(() {
        _error = 'No message ID provided';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use getMessageThread to fetch and mark as read
      final message = await ApiService.instance.getMessageThread(
        widget.messageId!,
      );

      if (mounted) {
        setState(() {
          _message = message;
          _isLoading = false;
          if (message == null) {
            _error = 'Message not found';
          }
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
    final t = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _message == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Message not found',
              style: t.bodyLarge?.copyWith(color: cs.error),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _loadMessage, child: const Text('Retry')),
          ],
        ),
      );
    }

    final message = _message!;

    return Container(
      width: double.infinity,
      color: cs.surface,
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
                _buildAuthorHeader(context, message, cs, t, showArchive: true),

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

                // Show replies if any
                if (message.replies.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Divider(color: cs.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Replies',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...message.replies.map(
                    (reply) => _buildReplyCard(context, reply, cs, t),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyCard(
    BuildContext context,
    Message reply,
    ColorScheme cs,
    TextTheme t,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorHeader(context, reply, cs, t, showArchive: false),
          const SizedBox(height: 12),
          Text(
            reply.message,
            style: t.bodyMedium?.copyWith(color: cs.onSurface, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader(
    BuildContext context,
    Message message,
    ColorScheme cs,
    TextTheme t, {
    bool showArchive = false,
  }) {
    final author = message.author;
    final authorName =
        author != null ? _getAuthorName(author) : 'High Aspirations';
    final showMentorChip = author != null && _isMentor(author);
    final showGuardianChip = author != null && _isGuardian(author);
    final showStaffChip = author != null && _isStaffOrAdmin(author);
    final relativeTime = _getRelativeTime(
      message.updatedAt ?? message.createdAt,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author avatar
        SizedBox(
          width: 40,
          height: 40,
          child: author != null
              ? _AuthorAvatar(user: author)
              : _SystemAvatar(),
        ),

        const SizedBox(width: 12),

        // Author name and mentor/staff chip
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      authorName,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showMentorChip) ...[
                    const SizedBox(width: 8),
                    Chit(
                      label: 'mentor',
                      backgroundColor: Colors.purple.shade100,
                      textColor: Colors.purple.shade700,
                    ),
                  ],
                  if (showGuardianChip) ...[
                    const SizedBox(width: 8),
                    Chit(
                      label: 'guardian',
                      backgroundColor: Colors.teal.shade100,
                      textColor: Colors.teal.shade700,
                    ),
                  ],
                  if (showStaffChip) ...[
                    const SizedBox(width: 8),
                    Chit(
                      label: 'staff',
                      backgroundColor: kHAPrimary.withOpacity(0.15),
                      textColor: kHAPrimary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Timestamp and archive button (only show archive on original message)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              relativeTime,
              style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (showArchive) ...[
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.archive_outlined, color: cs.onSurface),
                onPressed: () => _handleArchiveMessage(context, message),
                tooltip: 'Archive message',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 24,
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getAuthorName(User user) {
    final firstName = user.firstName?.trim() ?? '';
    final lastName = user.lastName?.trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? (user.email ?? '') : fullName;
  }

  bool _isMentor(User author) {
    return author.roles.contains(UserRole.mentor);
  }

  bool _isGuardian(User author) {
    return author.roles.contains(UserRole.parent);
  }

  bool _isStaffOrAdmin(User author) {
    return author.roles.contains(UserRole.staff) ||
        author.roles.contains(UserRole.admin);
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

  Future<void> _handleArchiveMessage(
    BuildContext context,
    Message message,
  ) async {
    try {
      await ApiService.instance.archiveMessage(
        messageId: message.id,
        archive: true,
      );

      if (context.mounted) {
        // Show snackbar with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message archived'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await ApiService.instance.archiveMessage(
                    messageId: message.id,
                    archive: false,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message unarchived'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to unarchive: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
        // Navigate back after archiving
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to archive message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SystemAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: const Color(0xFF1F2555), // kHAPrimary
        alignment: Alignment.center,
        child: const Text(
          'HA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
