// lib/core/session.dart
import 'package:flutter/foundation.dart';
import 'package:ha_mobile/data/mock/mock_users.dart';
import '../data/mock/mock_data.dart';
import '../business/user/entities/user.dart';

/// Keep if other parts of the app use this; otherwise prefer [currentUserId].
const String kCurrentUserId = 'current-user';

enum CurrentUserKind { mentee, mentor }

final ValueNotifier<CurrentUserKind> currentUserKind =
    ValueNotifier<CurrentUserKind>(CurrentUserKind.mentee);

User get currentUser =>
    currentUserKind.value == CurrentUserKind.mentee ? mockMentee : mockMentor;

/// If you want the actual mock's id for API calls, use this getter.
String get currentUserId => currentUser.id;

String get currentUserRoleLabel =>
    currentUserKind.value == CurrentUserKind.mentee ? 'Mentee' : 'Mentor';

void switchCurrentUser(CurrentUserKind kind) {
  if (currentUserKind.value != kind) {
    currentUserKind.value = kind;
  }
}
