// lib/presentation/widgets/list_tile_pulse.dart
import 'package:flutter/material.dart';
import '../../business/pulse/entities/pulse.dart';
import '../../core/utils/date_formatters.dart';

class ListTilePulse extends StatelessWidget {
  final Pulse pulse;

  const ListTilePulse({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return Icon(
                      starIndex <= pulse.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: cs.primary,
                      size: 16,
                    );
                  }),
                ),
                const Spacer(),
                // Date
                Text(
                  formatShortDate(pulse.createdAt),
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Highlight
            if (pulse.highlight.isNotEmpty) ...[
              Text(
                'Highlight',
                style: t.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pulse.highlight,
                style: t.bodyMedium?.copyWith(color: cs.onSurface),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            // Challenge
            if (pulse.challenge.isNotEmpty) ...[
              Text(
                'Challenge',
                style: t.labelSmall?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pulse.challenge,
                style: t.bodyMedium?.copyWith(color: cs.onSurface),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            // Thoughts
            if (pulse.thoughts.isNotEmpty) ...[
              Text(
                'Thoughts',
                style: t.labelSmall?.copyWith(
                  color: cs.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pulse.thoughts,
                style: t.bodyMedium?.copyWith(color: cs.onSurface),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            // Support Topics
            if (pulse.supportTopics.isNotEmpty) ...[
              Text(
                'Support Topics',
                style: t.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pulse.supportTopics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTopicIcon(topic),
                          size: 14,
                          color: cs.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTopicLabel(topic),
                          style: t.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTopicLabel(SupportTopic topic) {
    switch (topic) {
      case SupportTopic.school:
        return 'School';
      case SupportTopic.work:
        return 'Work';
      case SupportTopic.home:
        return 'Home';
      case SupportTopic.relationships:
        return 'Relationships';
      case SupportTopic.health:
        return 'Health';
      case SupportTopic.other:
        return 'Other';
    }
  }

  IconData _getTopicIcon(SupportTopic topic) {
    switch (topic) {
      case SupportTopic.school:
        return Icons.school;
      case SupportTopic.work:
        return Icons.work;
      case SupportTopic.home:
        return Icons.home;
      case SupportTopic.relationships:
        return Icons.people;
      case SupportTopic.health:
        return Icons.health_and_safety;
      case SupportTopic.other:
        return Icons.more_horiz;
    }
  }
}
