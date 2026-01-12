/// Lightweight references so we don't need full objects everywhere.
class UserRef {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? image; // asset/file/url
  final int? colorIndex; // 0..kProfileColors.length-1
  final String? phone;
  final String? email;
  final int? points; // Optional points for mentees

  const UserRef({
    required this.id,
    this.firstName,
    this.lastName,
    this.image,
    this.colorIndex,
    this.phone,
    this.email,
    this.points,
  });

  String get displayName =>
      [firstName, lastName].where((s) => (s ?? '').isNotEmpty).join(' ');
}

class TeamRef {
  final String id;
  final String name;
  const TeamRef({required this.id, required this.name});
}
