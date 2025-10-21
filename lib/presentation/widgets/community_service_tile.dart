import 'package:flutter/material.dart';

class CommunityServiceTile extends StatelessWidget {
  final int totalHours;
  final int totalEvents;
  final VoidCallback? onTap;

  const CommunityServiceTile({
    super.key,
    required this.totalHours,
    required this.totalEvents,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A), // Dark blue
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.home_work_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Middle section - Events and hours
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalEvents events',
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalHours}hrs • Community Service',
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side - View button
                Text(
                  'View',
                  style: t.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
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
