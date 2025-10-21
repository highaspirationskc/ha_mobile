/// A community service entity representing volunteer work performed by mentees
class CommunityService {
  final String id;
  final String name;
  final String description;
  final int hours;
  final String? location;
  final DateTime createdAt;

  const CommunityService({
    required this.id,
    required this.name,
    required this.description,
    required this.hours,
    this.location,
    required this.createdAt,
  });

  CommunityService copyWith({
    String? id,
    String? name,
    String? description,
    int? hours,
    String? location,
    DateTime? createdAt,
  }) {
    return CommunityService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommunityService &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.hours == hours &&
        other.location == location &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, hours, location, createdAt);
  }

  @override
  String toString() {
    return 'CommunityService(id: $id, name: $name, description: $description, hours: $hours, location: $location, createdAt: $createdAt)';
  }
}
