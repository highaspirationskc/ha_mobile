// lib/features/login/auth_check_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../../data/services/auth_storage.dart';
import '../../data/graphql/graphql_client.dart';
import '../../data/services/api_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/olympic_season_service.dart';
import '../../core/session.dart';
import '../../presentation/screens/root_shell.dart';
import 'login_screen.dart';

/// Screen that checks for stored authentication token on app startup
/// and validates it before navigating to the appropriate screen
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (kDebugMode) {
      print('🔍 Checking for stored authentication token...');
    }

    try {
      // Check if we have a stored token
      final storedToken = await AuthStorage.getToken();
      final storedUser = await AuthStorage.getUser();

      if (storedToken == null || storedUser == null) {
        if (kDebugMode) {
          print('❌ No stored token found, showing login screen');
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
        return;
      }

      if (kDebugMode) {
        print('✅ Found stored token, validating...');
      }

      // Restore token to GraphQL client
      GraphQLClientService.instance.setAuthToken(storedToken);

      // Validate token by attempting to fetch current user
      try {
        await ApiService.instance.getCurrentUser();

        if (kDebugMode) {
          print('✅ Token is valid, restoring session...');
        }

        // Restore user to session
        setAuthenticatedUser(storedUser);

        // Initialize services in the background (don't block navigation)
        _initializeServices();

        // Navigate to home screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RootShell()),
          );
        }
      } catch (e) {
        // Token is invalid or expired
        if (kDebugMode) {
          print('❌ Token validation failed: $e');
          print('🧹 Clearing invalid token...');
        }

        // Clear invalid token
        await AuthStorage.clearAuth();
        GraphQLClientService.instance.clearAuthToken();
        clearAuthenticatedUser();

        // Navigate to login screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during auth check: $e');
      }

      // On any error, clear storage and show login screen
      await AuthStorage.clearAuth();
      GraphQLClientService.instance.clearAuthToken();
      clearAuthenticatedUser();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  void _initializeServices() {
    // Fetch Olympic Season data in the background (don't block on errors)
    OlympicSeasonService.instance.fetchCurrentSeason().catchError((e) {
      if (kDebugMode) {
        print('⚠️ Failed to fetch Olympic Season: $e');
      }
    });

    // Initialize push notifications (don't block on errors)
    if (!kIsWeb) {
      NotificationService.instance.initialize().catchError((e) {
        if (kDebugMode) {
          print('⚠️ Failed to initialize notifications: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
