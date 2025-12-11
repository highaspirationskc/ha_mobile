/// A community service entity representing volunteer work performed by mentees
class CommunityService {
  final String id;
  final String name; // Maps to 'event' field from API
  final String description;
  final double hours; // Changed to double to match API Float type
  final String? location;
  final DateTime eventDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool approved;

  const CommunityService({
    required this.id,
    required this.name,
    required this.description,
    required this.hours,
    this.location,
    required this.eventDate,
    required this.createdAt,
    this.updatedAt,
    this.approved = false,
  });

  factory CommunityService.fromJson(Map<String, dynamic> json) {
    return CommunityService(
      id: json['id'].toString(),
      name: json['event'] as String,
      description: json['description'] as String? ?? '',
      hours: (json['hours'] as num).toDouble(),
      eventDate: DateTime.parse(json['eventDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      approved: json['approved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': name,
      'description': description,
      'hours': hours,
      'eventDate': eventDate.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'approved': approved,
    };
  }

  CommunityService copyWith({
    String? id,
    String? name,
    String? description,
    double? hours,
    String? location,
    DateTime? eventDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? approved,
  }) {
    return CommunityService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approved: approved ?? this.approved,
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
        other.eventDate == eventDate &&
        other.createdAt == createdAt &&
        other.approved == approved;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      hours,
      location,
      eventDate,
      createdAt,
      approved,
    );
  }

  @override
  String toString() {
    return 'CommunityService(id: $id, name: $name, description: $description, hours: $hours, eventDate: $eventDate, approved: $approved)';
  }
}
