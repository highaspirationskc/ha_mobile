import 'user_refs.dart';

/// Role-specific fields for a Mentee (keyed by the same userId).
class MenteeData {
  final String userId;

  // Relations
  final List<UserRef>? parents; // ?
  final UserRef? mentor; // ?
  final TeamRef? team; // ?

  // Attendance
  final int totalAttendance; // Total Attendance
  final int currentStreak; // Current Attendance Streak

  const MenteeData({
    required this.userId,
    this.parents,
    this.mentor,
    this.team,
    this.totalAttendance = 0,
    this.currentStreak = 0,
  });

  MenteeData copyWith({
    List<UserRef>? parents,
    UserRef? mentor,
    TeamRef? team,
    int? totalAttendance,
    int? currentStreak,
  }) {
    return MenteeData(
      userId: userId,
      parents: parents ?? this.parents,
      mentor: mentor ?? this.mentor,
      team: team ?? this.team,
      totalAttendance: totalAttendance ?? this.totalAttendance,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
