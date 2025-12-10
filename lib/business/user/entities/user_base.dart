import 'user_role.dart';

/// Identity + common profile fields only. No role-specific data here.
class User {
  final String id;

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? image;
  final int? colorIndex;

  final Set<UserRole> roles;

  const User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.image,
    this.colorIndex,
    this.roles = const {},
  });

  String get displayName =>
      [firstName, lastName].where((s) => (s ?? '').isNotEmpty).join(' ');

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? image,
    int? colorIndex,
    Set<UserRole>? roles,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      colorIndex: colorIndex ?? this.colorIndex,
      roles: roles ?? this.roles,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      // Support both 'image' and 'avatarUrl' from API
      image: (json['image'] ?? json['avatarUrl']) as String?,
      colorIndex: json['colorIndex'] as int?,
      roles: (json['role'] as String?) != null
          ? {UserRole.fromString(json['role'] as String)}
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'image': image,
      'colorIndex': colorIndex,
      'role': roles.isNotEmpty ? roles.first.value : null,
    };
  }
}
