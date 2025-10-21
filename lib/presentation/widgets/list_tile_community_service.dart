import 'package:flutter/material.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../core/utils/date_formatters.dart';

class ListTileCommunityService extends StatelessWidget {
  final CommunityService service;
  final VoidCallback? onTap;

  const ListTileCommunityService({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A), // Dark blue
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Middle section - Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.description,
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${service.hours}hrs',
                            style: t.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: t.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatShortDate(service.createdAt),
                            style: t.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
