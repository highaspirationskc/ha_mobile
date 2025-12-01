enum UserRole {
  mentee,
  mentor,
  staff,
  parent,
  volunteer;

  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value.toLowerCase(),
      orElse: () => UserRole.mentee,
    );
  }
}
