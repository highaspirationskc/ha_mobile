import 'user_role.dart';

/// Identity + common profile fields only. No role-specific data here.
class User {
  final String id;

  // Core identity / profile
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone; // ?
  final String? image; // ? asset/file/url
  final int? colorIndex; // profile color index (0..11)

  /// Roles this user has (drives which role-data models exist for them).
  final Set<UserRole> roles;

  const User({
    required this.id,
    required this.email,
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
}
