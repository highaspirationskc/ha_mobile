// lib/data/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../business/auth/entities/auth_response.dart';
import '../graphql/graphql_client.dart';
import '../graphql/documents/mutations/mutations.dart';

/// Service for handling authentication operations
class AuthService {
  AuthService._() {
    _graphQLClient = GraphQLClientService.instance;
    // Ensure GraphQL client is initialized
    _graphQLClient.initialize();
  }
  static final instance = AuthService._();

  late final GraphQLClientService _graphQLClient;

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('🔐 Attempting login for: $email');
      print('📡 API Endpoint: https://api.highaspirationskc.org/graphql');
    }

    try {
      final result = await _graphQLClient.client.mutate(
        MutationOptions(
          document: gql(loginMutation),
          variables: {
            'input': {'email': email, 'password': password},
          },
        ),
      );

      if (kDebugMode) {
        print('📦 Response received');
        print('   Has exception: ${result.hasException}');
        print('   Has data: ${result.data != null}');
        if (result.hasException) {
          print('   Exception details: ${result.exception}');
          print('   GraphQL errors: ${result.exception?.graphqlErrors}');
          print('   Link exception: ${result.exception?.linkException}');
        }
        if (result.data != null) {
          print('   Data: ${result.data}');
        }
      }

      if (result.hasException) {
        // Check for network errors
        if (result.exception?.linkException != null) {
          if (kDebugMode) {
            print('❌ Network error: ${result.exception!.linkException}');
          }
          throw Exception(
            'Network error: Unable to connect to the server. '
            'Please check your internet connection.',
          );
        }

        // Check for GraphQL errors
        if (result.exception?.graphqlErrors.isNotEmpty == true) {
          final errorMessage = result.exception!.graphqlErrors.first.message;
          if (kDebugMode) {
            print('❌ GraphQL error: $errorMessage');
          }
          throw Exception(errorMessage);
        }

        // Generic error
        throw Exception('Login failed. Please check your credentials.');
      }

      final data = result.data?['login'];
      if (data == null) {
        if (kDebugMode) {
          print('❌ No login data in response');
        }
        throw Exception('Invalid response from server');
      }

      if (kDebugMode) {
        print('✅ Login successful!');
      }

      final authResponse = AuthResponse.fromJson(data);
      _graphQLClient.setAuthToken(authResponse.token);

      return authResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login exception: $e');
      }
      rethrow;
    }
  }

  /// Logout and clear auth token
  void logout() {
    _graphQLClient.clearAuthToken();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _graphQLClient.isAuthenticated;

  /// Get the current auth token
  String? get authToken => _graphQLClient.authToken;
}
