// lib/core/session.dart
import 'package:flutter/foundation.dart';
import 'package:ha_mobile/data/mock/mock_users.dart';
import '../business/user/entities/user.dart';
import '../business/auth/entities/auth_response.dart' as auth;

/// Keep if other parts of the app use this; otherwise prefer [currentUserId].
const String kCurrentUserId = 'current-user';

enum CurrentUserKind { mentee, mentor, parent, volunteer }

final ValueNotifier<CurrentUserKind> currentUserKind =
    ValueNotifier<CurrentUserKind>(CurrentUserKind.mentee);

// Authenticated user from API
auth.User? _authenticatedUser;

/// Set the authenticated user from login
void setAuthenticatedUser(auth.User user) {
  _authenticatedUser = user;
  // Update currentUserKind based on the authenticated user's role
  _updateUserKindFromRole(user.role);
}

/// Clear the authenticated user on logout
void clearAuthenticatedUser() {
  _authenticatedUser = null;
  // Reset to default mentee when logged out
  currentUserKind.value = CurrentUserKind.mentee;
}

/// Update currentUserKind based on role string from API
void _updateUserKindFromRole(String? role) {
  if (kDebugMode) {
    print('🔄 Updating user kind from role: $role');
  }

  if (role == null) {
    if (kDebugMode) {
      print(
        '⚠️ Role is null, keeping current user kind: ${currentUserKind.value}',
      );
    }
    return;
  }

  final normalizedRole = role.toLowerCase();
  final previousKind = currentUserKind.value;

  switch (normalizedRole) {
    case 'mentor':
      currentUserKind.value = CurrentUserKind.mentor;
      break;
    case 'volunteer':
    case 'staff':
    case 'admin':
      currentUserKind.value = CurrentUserKind.volunteer;
      break;
    case 'parent':
      currentUserKind.value = CurrentUserKind.parent;
      break;
    case 'mentee':
    default:
      currentUserKind.value = CurrentUserKind.mentee;
      break;
  }

  if (kDebugMode) {
    print('✅ User kind updated: $previousKind → ${currentUserKind.value}');
  }
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

String get currentUserRoleLabel {
  if (_authenticatedUser?.role != null) {
    return _authenticatedUser!.role!;
  }

  return switch (currentUserKind.value) {
    CurrentUserKind.mentee => 'Mentee',
    CurrentUserKind.parent => 'Parent',
    CurrentUserKind.volunteer => 'Volunteer',
    CurrentUserKind.mentor => 'Mentor',
  };
}

void switchCurrentUser(CurrentUserKind kind) {
  if (currentUserKind.value != kind) {
    currentUserKind.value = kind;
  }
}
