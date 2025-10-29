import 'package:flutter/material.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../business/teams/entities/team.dart';
import '../../core/theme/color_schemes.dart';

class TeamTile extends StatelessWidget {
  final TeamSummary? teamSummary;
  final VoidCallback? onTap;

  const TeamTile({super.key, this.teamSummary, this.onTap});

  // Helper method to get team color from TeamColor enum
  Color _getTeamColor(TeamColor color) {
    return switch (color) {
      TeamColor.red => kProfileColors[0], // red
      TeamColor.green => kProfileColors[4], // green
      TeamColor.blue => kProfileColors[7], // blue
      TeamColor.yellow => kProfileColors[2], // amber/yellow
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Determine display values
    final displayName = teamSummary?.name ?? 'Team';
    final displaySubtitle = teamSummary != null
        ? '${teamSummary!.colorName} • Rank #${teamSummary!.rank} • ${teamSummary!.points} pts'
        : 'Connect with your team';
    final teamColor = teamSummary != null
        ? _getTeamColor(teamSummary!.color)
        : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                // Left side - Team Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: teamColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.group, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 16),

                // Middle section - Team info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displaySubtitle,
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
