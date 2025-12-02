// lib/business/user/entities/family_member.dart

import 'user_base.dart';

/// Represents a family member relationship between two users
class FamilyMember {
  final String id;
  final User user;
  final User relatedUser;
  final String relationshipType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyMember({
    required this.id,
    required this.user,
    required this.relatedUser,
    required this.relationshipType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      relatedUser: User.fromJson(json['relatedUser'] as Map<String, dynamic>),
      relationshipType: json['relationshipType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'relatedUser': relatedUser.toJson(),
      'relationshipType': relationshipType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
