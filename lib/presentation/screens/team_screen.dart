import 'package:flutter/material.dart';
import 'package:ha_mobile/core/theme/brand_colors.dart';
import '../../business/leaderboard/entities/leaderboard.dart';
import '../../business/teams/entities/team.dart';
import '../../data/services/api_service.dart';
import '../widgets/tabs.dart';
import '../widgets/podium.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  Leaderboard? _leaderboard;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final leaderboard = await ApiService.instance.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load leaderboard';
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to get team color from TeamColor enum
  Color _getTeamColor(TeamColor color) {
    return switch (color) {
      TeamColor.red => kTeamRed,
      TeamColor.green => kTeamGreen,
      TeamColor.blue => kTeamBlue,
      TeamColor.yellow => kTeamYellow,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 1.0],
                  colors: [Colors.white, kHAPrimary],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false, // Allow content to extend behind bottom nav bar
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HATabs(
                    controller: _tabController,
                    tabNames: const ['Teams', 'Mentees'],
                  ),

                  const SizedBox(height: 16),

                  // Content based on loading state
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: cs.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: t.bodyLarge?.copyWith(color: cs.error),
                                ),
                              ],
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTeamsTab(context, cs, t),
                              _buildMenteesTab(context, cs, t),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab(BuildContext context, ColorScheme cs, TextTheme t) {
    final leaderboard = _leaderboard!;
    final teamsByRank = leaderboard.teamsByRank;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 1.5, // Enough space for podiums + list content
        child: Stack(
          children: [
            // Podiums container at top (1/3 screen height)
            if (teamsByRank.isNotEmpty)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTopThreeTeamsPodium(context, teamsByRank, cs, t),
              ),

            // Teams list starting at 1/3 down the screen
            Positioned(
              top: screenHeight / 4,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Rankings Section
                  _buildSectionHeader('Team Rankings', cs, t),
                  const SizedBox(height: 16),
                  ...teamsByRank.map((team) => _buildTeamTile(team, cs, t)),

                  const SizedBox(height: 120), // Space to scroll past nav bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenteesTab(BuildContext context, ColorScheme cs, TextTheme t) {
    final leaderboard = _leaderboard!;
    final topMentees = leaderboard.topMentees.take(10).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top 3 Mentees Podium
          if (topMentees.isNotEmpty)
            _buildTopThreeMenteesPodium(topMentees, cs, t),

          const SizedBox(height: 32),

          // Top 10 Mentees Section
          _buildSectionHeader('Top 10 Mentees', cs, t),
          const SizedBox(height: 16),
          ...topMentees.map((mentee) => _buildMenteeTile(mentee, cs, t)),

          const SizedBox(height: 120), // Space to scroll past nav bar
        ],
      ),
    );
  }

  Widget _buildTopThreeTeamsPodium(
    BuildContext context,
    List<Team> teams,
    ColorScheme cs,
    TextTheme t,
  ) {
    final first = teams.length > 0 ? teams[0] : null;
    final second = teams.length > 1 ? teams[1] : null;
    final third = teams.length > 2 ? teams[2] : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth,
      height: screenHeight / 3, // 1/3 screen size container
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place (left)
            if (second != null)
              _buildPodiumPosition(
                context: context,
                team: second,
                position: 2,
                height: 240,
                size: screenWidth * 0.28,
                cs: cs,
                t: t,
              ),

            // 1st place (center)
            if (first != null)
              _buildPodiumPosition(
                context: context,
                team: first,
                position: 1,
                height: 280,
                size: screenWidth * 0.32,
                cs: cs,
                t: t,
              ),

            // 3rd place (right)
            if (third != null)
              _buildPodiumPosition(
                context: context,
                team: third,
                position: 3,
                height: 200,
                size: screenWidth * 0.26,
                cs: cs,
                t: t,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreeMenteesPodium(
    List<MenteeRanking> mentees,
    ColorScheme cs,
    TextTheme t,
  ) {
    final first = mentees.length > 0 ? mentees[0] : null;
    final second = mentees.length > 1 ? mentees[1] : null;
    final third = mentees.length > 2 ? mentees[2] : null;

    return Container(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place (left)
          if (second != null)
            Expanded(
              child: _buildMenteePodiumPosition(
                mentee: second,
                position: 2,
                height: 120,
                size: 40,
                cs: cs,
                t: t,
              ),
            ),

          const SizedBox(width: 16),

          // 1st place (center)
          if (first != null)
            Expanded(
              child: _buildMenteePodiumPosition(
                mentee: first,
                position: 1,
                height: 120,
                size: 80,
                cs: cs,
                t: t,
              ),
            ),

          const SizedBox(width: 16),

          // 3rd place (right)
          if (third != null)
            Expanded(
              child: _buildMenteePodiumPosition(
                mentee: third,
                position: 3,
                height: 80,
                size: 50,
                cs: cs,
                t: t,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition({
    required BuildContext context,
    required Team team,
    required int position,
    required double height,
    required double size,
    required ColorScheme cs,
    required TextTheme t,
  }) {
    final teamColor = _getTeamColor(team.color);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Team Name
        Text(
          team.name,
          style: t.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Points
        Text(
          '${team.points} pts',
          style: t.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Podium - use the height parameter passed in
        Podium(
          baseColor: teamColor,
          rank: position,
          borderRadius: BorderRadius.zero,
          width: size,
          height: height,
        ),
      ],
    );
  }

  Widget _buildMenteePodiumPosition({
    required MenteeRanking mentee,
    required int position,
    required double height,
    required double size,
    required ColorScheme cs,
    required TextTheme t,
  }) {
    final teamColor = mentee.team != null
        ? _getTeamColor(mentee.team!.color)
        : cs.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Mentee Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: teamColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: position == 1 ? Colors.amber : teamColor.withOpacity(0.5),
              width: position == 1 ? 3 : 2,
            ),
          ),
          child: Center(
            child: Text(
              mentee.mentee.firstName?.substring(0, 1).toUpperCase() ?? '?',
              style: t.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: teamColor,
                fontSize: size * 0.4,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Mentee Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            mentee.mentee.displayName,
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 4),

        // Points
        Text(
          '${mentee.points} pts',
          style: t.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        // Podium Base
        Container(
          height: height - size - 50,
          decoration: BoxDecoration(
            color: position == 1
                ? Colors.amber.withOpacity(0.2)
                : cs.surfaceVariant.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(
              color: position == 1 ? Colors.amber : cs.outline.withOpacity(0.3),
            ),
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: t.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: position == 1 ? Colors.amber[700] : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs, TextTheme t) {
    return Text(
      title,
      style: t.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }

  Widget _buildTeamTile(Team team, ColorScheme cs, TextTheme t) {
    final teamColor = _getTeamColor(team.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: team.rank == 1 ? Colors.amber : cs.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${team.rank}',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: team.rank == 1 ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Team Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: teamColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.group, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          // Team Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${team.colorName} • ${team.mentorCount} mentors • ${team.menteeCount} mentees',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${team.points} pts',
            style: t.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenteeTile(
    MenteeRanking menteeRanking,
    ColorScheme cs,
    TextTheme t,
  ) {
    final teamColor = menteeRanking.team != null
        ? _getTeamColor(menteeRanking.team!.color)
        : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: menteeRanking.rank <= 3 ? Colors.amber : cs.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${menteeRanking.rank}',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: menteeRanking.rank <= 3
                      ? Colors.white
                      : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Mentee Avatar/Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: teamColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: teamColor.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                menteeRanking.mentee.firstName?.substring(0, 1).toUpperCase() ??
                    '?',
                style: t.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: teamColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Mentee Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menteeRanking.mentee.displayName,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  menteeRanking.team?.name ?? 'No Team',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // Points breakdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${menteeRanking.points} pts',
                style: t.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${menteeRanking.attendance}a + ${menteeRanking.communityServiceEvents}c',
                style: t.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
