import 'user_refs.dart';
import '../../teams/entities/team.dart';

/// Team summary with essential info for mentees
class TeamSummary {
  final String id;
  final String name;
  final TeamColor color;
  final int points;
  final int rank;

  const TeamSummary({
    required this.id,
    required this.name,
    required this.color,
    required this.points,
    required this.rank,
  });

  /// Helper method to get the display color name
  String get colorName {
    return switch (color) {
      TeamColor.red => 'Red',
      TeamColor.green => 'Green',
      TeamColor.blue => 'Blue',
      TeamColor.yellow => 'Yellow',
    };
  }

  TeamSummary copyWith({
    String? id,
    String? name,
    TeamColor? color,
    int? points,
    int? rank,
  }) {
    return TeamSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      points: points ?? this.points,
      rank: rank ?? this.rank,
    );
  }
}

/// Role-specific fields for a Mentee (keyed by the same userId).
class MenteeData {
  final String userId;

  final List<UserRef>? parents;
  final UserRef? mentor;
  final TeamRef? team; 

  final String? teamId;
  final TeamSummary? teamSummary;

  final int totalAttendance;
  final int currentStreak;

  const MenteeData({
    required this.userId,
    this.parents,
    this.mentor,
    this.team,
    this.teamId,
    this.teamSummary,
    this.totalAttendance = 0,
    this.currentStreak = 0,
  });

  MenteeData copyWith({
    List<UserRef>? parents,
    UserRef? mentor,
    TeamRef? team,
    String? teamId,
    TeamSummary? teamSummary,
    int? totalAttendance,
    int? currentStreak,
  }) {
    return MenteeData(
      userId: userId,
      parents: parents ?? this.parents,
      mentor: mentor ?? this.mentor,
      team: team ?? this.team,
      teamId: teamId ?? this.teamId,
      teamSummary: teamSummary ?? this.teamSummary,
      totalAttendance: totalAttendance ?? this.totalAttendance,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
