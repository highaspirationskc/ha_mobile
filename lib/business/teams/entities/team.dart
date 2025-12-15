import '../../user/entities/user_refs.dart';

/// Available team colors
enum TeamColor { red, green, blue, yellow }

/// Represents a team with color, name, and members
class Team {
  final String id;
  final String name;
  final TeamColor color;
  final String? iconUrl;
  final List<UserRef> mentors;
  final List<UserRef> mentees;
  final int totalPoints;
  final double totalCommunityServiceHours;
  final int rank; // Computed based on totalPoints

  const Team({
    required this.id,
    required this.name,
    required this.color,
    this.iconUrl,
    this.mentors = const [],
    this.mentees = const [],
    this.totalPoints = 0,
    this.totalCommunityServiceHours = 0,
    this.rank = 0,
  });

  /// Convenience getters for counts
  int get mentorCount => mentors.length;
  int get menteeCount => mentees.length;

  /// Alias for backwards compatibility
  int get points => totalPoints;

  Team copyWith({
    String? id,
    String? name,
    TeamColor? color,
    String? iconUrl,
    List<UserRef>? mentors,
    List<UserRef>? mentees,
    int? totalPoints,
    double? totalCommunityServiceHours,
    int? rank,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      iconUrl: iconUrl ?? this.iconUrl,
      mentors: mentors ?? this.mentors,
      mentees: mentees ?? this.mentees,
      totalPoints: totalPoints ?? this.totalPoints,
      totalCommunityServiceHours:
          totalCommunityServiceHours ?? this.totalCommunityServiceHours,
      rank: rank ?? this.rank,
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

  /// Parse TeamColor from API string
  static TeamColor parseColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'red':
        return TeamColor.red;
      case 'green':
        return TeamColor.green;
      case 'blue':
        return TeamColor.blue;
      case 'yellow':
        return TeamColor.yellow;
      default:
        return TeamColor.blue; // Default fallback
    }
  }

  /// Create Team from API JSON response
  factory Team.fromJson(Map<String, dynamic> json) {
    // Parse mentors
    final mentorsData = json['mentors'] as List<dynamic>? ?? [];
    final mentors = mentorsData.map((m) {
      final map = m as Map<String, dynamic>;
      return UserRef(
        id: map['id'].toString(),
        firstName: map['firstName'] as String?,
        lastName: map['lastName'] as String?,
        image: map['avatarUrl'] as String?,
      );
    }).toList();

    // Parse mentees
    final menteesData = json['mentees'] as List<dynamic>? ?? [];
    final mentees = menteesData.map((m) {
      final map = m as Map<String, dynamic>;
      return UserRef(
        id: map['id'].toString(),
        firstName: map['firstName'] as String?,
        lastName: map['lastName'] as String?,
        image: map['avatarUrl'] as String?,
      );
    }).toList();

    return Team(
      id: json['id'].toString(),
      name: json['name'] as String,
      color: parseColor(json['color'] as String? ?? 'blue'),
      iconUrl: json['iconUrl'] as String?,
      mentors: mentors,
      mentees: mentees,
      totalPoints: json['totalPoints'] as int? ?? 0,
      totalCommunityServiceHours:
          (json['totalCommunityServiceHours'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  String toString() =>
      'Team(id: $id, name: $name, color: $colorName, rank: $rank, points: $totalPoints)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.rank == rank &&
        other.totalPoints == totalPoints;
  }

  @override
  int get hashCode => Object.hash(id, name, color, rank, totalPoints);
}
