import 'package:flutter/material.dart';
import '../../../presentation/widgets/avatar.dart';

class MenteeListItem extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? image;
  final int? colorIndex;
  final int points;
  final VoidCallback? onTap;

  const MenteeListItem({
    super.key,
    this.firstName,
    this.lastName,
    this.image,
    this.colorIndex,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Avatar(
              firstName: firstName,
              lastName: lastName,
              image: image,
              colorIndex: colorIndex,
              size: 56,
              editable: false,
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              '${firstName ?? ''} ${lastName ?? ''}'.trim(),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Points
            Text(
              '$points pts',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
