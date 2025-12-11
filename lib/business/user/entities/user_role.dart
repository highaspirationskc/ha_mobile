enum UserRole {
  mentee,
  mentor,
  staff,
  admin,
  parent,
  volunteer;

  String get value => name;

  static UserRole fromString(String value) {
    final normalized = value.toLowerCase();
    // Handle API returning "Guardian" for parent role
    if (normalized == 'guardian') {
      return UserRole.parent;
    }
    return UserRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => UserRole.mentee,
    );
  }
}
