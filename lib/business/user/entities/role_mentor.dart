import 'user_refs.dart';

/// Role-specific fields for a Mentor (keyed by the same userId).
class MentorData {
  final String userId;

  /// People they mentor (can be empty).
  final List<UserRef>? mentees; // ?

  const MentorData({required this.userId, this.mentees});

  MentorData copyWith({List<UserRef>? mentees}) {
    return MentorData(userId: userId, mentees: mentees ?? this.mentees);
  }
}
