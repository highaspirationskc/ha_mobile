import '../../teams/entities/team.dart';
import '../../user/entities/user_refs.dart';
import '../../user/entities/role_mentee.dart';

/// Individual mentee entry in leaderboard
class MenteeRanking {
  final UserRef mentee;
  final TeamSummary? team;
  final int points;
  final int rank;
  final int attendance;
  final int communityServiceEvents;

  const MenteeRanking({
    required this.mentee,
    required this.points,
    required this.rank,
    this.team,
    this.attendance = 0,
    this.communityServiceEvents = 0,
  });

  MenteeRanking copyWith({
    UserRef? mentee,
    TeamSummary? team,
    int? points,
    int? rank,
    int? attendance,
    int? communityServiceEvents,
  }) {
    return MenteeRanking(
      mentee: mentee ?? this.mentee,
      team: team ?? this.team,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      attendance: attendance ?? this.attendance,
      communityServiceEvents:
          communityServiceEvents ?? this.communityServiceEvents,
    );
  }
}

/// Complete leaderboard data
class Leaderboard {
  final List<Team> teams;
  final List<MenteeRanking> topMentees;
  final DateTime lastUpdated;

  const Leaderboard({
    required this.teams,
    required this.topMentees,
    required this.lastUpdated,
  });

  Leaderboard copyWith({
    List<Team>? teams,
    List<MenteeRanking>? topMentees,
    DateTime? lastUpdated,
  }) {
    return Leaderboard(
      teams: teams ?? this.teams,
      topMentees: topMentees ?? this.topMentees,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get teams sorted by rank (ascending)
  List<Team> get teamsByRank {
    final sortedTeams = List<Team>.from(teams);
    sortedTeams.sort((a, b) => a.rank.compareTo(b.rank));
    return sortedTeams;
  }

  /// Get teams sorted by points (descending)
  List<Team> get teamsByPoints {
    final sortedTeams = List<Team>.from(teams);
    sortedTeams.sort((a, b) => b.points.compareTo(a.points));
    return sortedTeams;
  }
}
