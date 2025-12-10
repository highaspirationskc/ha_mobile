import '../../user/entities/user.dart';
import 'event_type.dart';

class Event {
  final String id;
  final String name;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String? imageUrl;
  final EventType eventType;
  final String? olympicSeasonId;
  final List<User> arrivedUsers;
  final List<User> registeredUsers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? createdBy;

  const Event({
    required this.id,
    required this.name,
    this.description,
    required this.eventDate,
    this.location,
    this.imageUrl,
    required this.eventType,
    this.olympicSeasonId,
    this.arrivedUsers = const [],
    this.registeredUsers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      eventType: EventType.fromJson(json['eventType'] as Map<String, dynamic>),
      olympicSeasonId: json['olympicSeason']?['id']?.toString(),
      arrivedUsers:
          (json['arrivedUsers'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      registeredUsers:
          (json['registeredUsers'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] != null
          ? User.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'eventType': eventType.toJson(),
      'olympicSeasonId': olympicSeasonId,
      'arrivedUsers': arrivedUsers.map((u) => u.toJson()).toList(),
      'registeredUsers': registeredUsers.map((u) => u.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy?.toJson(),
    };
  }

  int get arrivedCount => arrivedUsers.length;
  int get registeredCount => registeredUsers.length;
  int get attendeeCount => arrivedUsers.length; // Legacy compatibility

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if a user is registered for this event
  bool isUserRegistered(String userId) {
    return registeredUsers.any((u) => u.id == userId);
  }

  /// Check if a user has checked in (arrived) at this event
  bool isUserCheckedIn(String userId) {
    return arrivedUsers.any((u) => u.id == userId);
  }
}
