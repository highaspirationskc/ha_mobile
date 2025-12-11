// lib/business/mentee_spotlight/entities/mentee_spotlight.dart

import '../../user/entities/user_base.dart';
import '../../user/entities/user_role.dart';

/// A mentee spotlight entity representing a featured mentee with a description
/// written by a staff member
class MenteeSpotlight {
  final String id;
  final User mentee;
  final String description;
  final String? imageUrl;
  final User? author; // Staff member who wrote the spotlight
  final String? teamName; // Team the mentee belongs to
  final int points; // Points the mentee has earned
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenteeSpotlight({
    required this.id,
    required this.mentee,
    required this.description,
    this.imageUrl,
    this.author,
    this.teamName,
    this.points = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenteeSpotlight.fromJson(Map<String, dynamic> json) {
    return MenteeSpotlight(
      id: json['id'] as String,
      mentee: User(
        id: json['mentee']['id'] as String,
        email: json['mentee']['email'] as String,
        firstName: json['mentee']['firstName'] as String?,
        lastName: json['mentee']['lastName'] as String?,
        image: json['mentee']['avatarUrl'] as String?,
        roles: json['mentee']['role'] != null
            ? {UserRole.fromString(json['mentee']['role'] as String)}
            : {},
      ),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      teamName: json['teamName'] as String?,
      points: json['points'] as int? ?? 0,
      author: json['author'] != null
          ? User(
              id: json['author']['id'] as String,
              email: json['author']['email'] as String,
              firstName: json['author']['firstName'] as String?,
              lastName: json['author']['lastName'] as String?,
              image: json['author']['avatarUrl'] as String?,
              roles: json['author']['role'] != null
                  ? {UserRole.fromString(json['author']['role'] as String)}
                  : {},
            )
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentee': mentee.toJson(),
      'description': description,
      'imageUrl': imageUrl,
      'teamName': teamName,
      'points': points,
      'author': author?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MenteeSpotlight copyWith({
    String? id,
    User? mentee,
    String? description,
    String? title,
    String? imageUrl,
    User? author,
    String? teamName,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenteeSpotlight(
      id: id ?? this.id,
      mentee: mentee ?? this.mentee,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      teamName: teamName ?? this.teamName,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenteeSpotlight &&
        other.id == id &&
        other.mentee == mentee &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.teamName == teamName &&
        other.points == points &&
        other.author == author &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      mentee,
      description,
      imageUrl,
      teamName,
      points,
      author,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenteeSpotlight(id: $id, mentee: ${mentee.displayName}, description: $description, createdAt: $createdAt)';
  }
}
