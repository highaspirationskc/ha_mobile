import 'package:flutter/material.dart';

import '../../business/messages/entities/message.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_role.dart';
import '../../core/theme/brand_colors.dart';
import 'chit.dart';

class ListTileMessage extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const ListTileMessage({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final author = message.author;
    final authorName = author != null ? _fullName(author) : 'High Aspirations';
    final showMentorChip = author != null && _isMentor(author);
    final showGuardianChip = author != null && _isGuardian(author);
    final showStaffChip = author != null && _isStaffOrAdmin(author);
    final rel = _relativeTime(message.updatedAt ?? message.createdAt);
    final isRead = message.isRead;

    return Material(
      color: isRead ? cs.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: author != null
                    ? _AuthorAvatar(user: author)
                    : _SystemAvatar(),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rel,
                          style: t.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      message.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Text(
                      message.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  String _fullName(User u) {
    final f = u.firstName?.trim() ?? '';
    final l = u.lastName?.trim() ?? '';
    final both = '$f $l'.trim();
    return both.isEmpty ? (u.email ?? '') : both;
  }

  bool _isMentor(User author) =>
      author.roles.contains(UserRole.mentor);

  bool _isGuardian(User author) =>
      author.roles.contains(UserRole.parent);

  bool _isStaffOrAdmin(User author) =>
      author.roles.contains(UserRole.staff) ||
      author.roles.contains(UserRole.admin);

  String _relativeTime(DateTime when) {
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
}

/// Fallback avatar for system/automated messages with no author.
class _SystemAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: kHAPrimary,
        alignment: Alignment.center,
        child: const Text(
          'HA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
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
      borderRadius: BorderRadius.circular(18),
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

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
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
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
