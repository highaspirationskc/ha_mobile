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
    final authorName = _fullName(author);
    final showMentorChip = _isMentor(author);
    final showGuardianChip = _isGuardian(author);
    final showStaffChip = _isStaffOrAdmin(author);
    final rel = _relativeTime(message.updatedAt ?? message.createdAt);
    // Note: message.read is available when we need to implement read/unread status

    return Material(
      // All messages treated as unread for now (white background)
      color: Colors.white, // isRead ? cs.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar (36x36) with same look as mini avatars
              SizedBox(
                width: 36,
                height: 36,
                child: _AuthorAvatar(user: author),
              ),
              const SizedBox(width: 10),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name + optional mentor chip, trailing time
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

                    // Subject (bold, single line)
                    Text(
                      message.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    // Snippet (muted, single line)
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

  /// Show the "mentor" chip if the author is a mentor
  bool _isMentor(User author) {
    return author.roles.contains(UserRole.mentor);
  }

  /// Show the "guardian" chip if the author is a parent/guardian
  bool _isGuardian(User author) {
    return author.roles.contains(UserRole.parent);
  }

  /// Show the "staff" chip if the author is staff or admin
  bool _isStaffOrAdmin(User author) {
    return author.roles.contains(UserRole.staff) ||
        author.roles.contains(UserRole.admin);
  }

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

class _AuthorAvatar extends StatelessWidget {
  final User user;
  const _AuthorAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final img = user.image ?? '';
    // Use your AvatarMini look with a slightly larger size (36).
    // If AvatarMini doesn't support size, do a local CircleAvatar fallback.
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

          // white border 2px like your mini avatars
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
