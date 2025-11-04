// lib/core/session.dart
import 'package:flutter/foundation.dart';
import 'package:ha_mobile/data/mock/mock_users.dart';
import '../business/user/entities/user.dart';
import '../business/auth/entities/auth_response.dart' as auth;

/// Keep if other parts of the app use this; otherwise prefer [currentUserId].
const String kCurrentUserId = 'current-user';

enum CurrentUserKind { mentee, mentor }

final ValueNotifier<CurrentUserKind> currentUserKind =
    ValueNotifier<CurrentUserKind>(CurrentUserKind.mentee);

// Authenticated user from API
auth.User? _authenticatedUser;

/// Set the authenticated user from login
void setAuthenticatedUser(auth.User user) {
  _authenticatedUser = user;
}

/// Clear the authenticated user on logout
void clearAuthenticatedUser() {
  _authenticatedUser = null;
}

/// Get the authenticated user's ID
String? get authenticatedUserId => _authenticatedUser?.id;

/// Get the authenticated user's full name
String? get authenticatedUserName => _authenticatedUser?.fullName;

/// Check if user is authenticated
bool get isAuthenticated => _authenticatedUser != null;

// Legacy mock user support (fallback for development)
User get currentUser =>
    currentUserKind.value == CurrentUserKind.mentee ? mockMentee : mockMentor;

/// If you want the actual mock's id for API calls, use this getter.
String get currentUserId => authenticatedUserId ?? currentUser.id;

String get currentUserRoleLabel =>
    _authenticatedUser?.role ??
    (currentUserKind.value == CurrentUserKind.mentee ? 'Mentee' : 'Mentor');

void switchCurrentUser(CurrentUserKind kind) {
  if (currentUserKind.value != kind) {
    currentUserKind.value = kind;
  }
}
