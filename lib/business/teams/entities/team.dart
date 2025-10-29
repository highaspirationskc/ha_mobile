import '../../user/entities/user_refs.dart';

/// Available team colors
enum TeamColor { red, green, blue, yellow }

/// Represents a team with color, name, and mentors
class Team {
  final String id;
  final String name;
  final TeamColor color;
  final List<UserRef> mentors;
  final int rank;
  final int points;
  final int mentorCount;
  final int menteeCount;

  const Team({
    required this.id,
    required this.name,
    required this.color,
    this.mentors = const [],
    this.rank = 0,
    this.points = 0,
    this.mentorCount = 0,
    this.menteeCount = 0,
  });

  Team copyWith({
    String? id,
    String? name,
    TeamColor? color,
    List<UserRef>? mentors,
    int? rank,
    int? points,
    int? mentorCount,
    int? menteeCount,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      mentors: mentors ?? this.mentors,
      rank: rank ?? this.rank,
      points: points ?? this.points,
      mentorCount: mentorCount ?? this.mentorCount,
      menteeCount: menteeCount ?? this.menteeCount,
    );
  }

  /// Helper method to get the display color name
  String get colorName {
    return switch (color) {
      TeamColor.red => 'Red',
      TeamColor.green => 'Green',
      TeamColor.blue => 'Blue',
      TeamColor.yellow => 'Yellow',
    };
  }

  @override
  String toString() =>
      'Team(id: $id, name: $name, color: $colorName, rank: $rank, points: $points)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.rank == rank &&
        other.points == points &&
        other.mentorCount == mentorCount &&
        other.menteeCount == menteeCount;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, rank, points, mentorCount, menteeCount);
}
