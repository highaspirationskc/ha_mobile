/// Role-specific fields for Staff (keyed by the same userId).
class StaffData {
  final String userId;

  final String? title; // ?
  final String? department; // ?
  final List<String>? scopes; // ? permissions / capabilities

  const StaffData({
    required this.userId,
    this.title,
    this.department,
    this.scopes,
  });

  StaffData copyWith({
    String? title,
    String? department,
    List<String>? scopes,
  }) {
    return StaffData(
      userId: userId,
      title: title ?? this.title,
      department: department ?? this.department,
      scopes: scopes ?? this.scopes,
    );
  }
}
