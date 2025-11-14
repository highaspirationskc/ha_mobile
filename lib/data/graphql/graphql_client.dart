// lib/data/graphql/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';

/// Service for managing GraphQL client configuration and initialization
class GraphQLClientService {
  GraphQLClientService._();
  static final instance = GraphQLClientService._();

  GraphQLClient? _client;
  String? _authToken;
  bool _isInitialized = false;

  /// Initialize the GraphQL client with the API endpoint
  /// Safe to call multiple times - will only initialize once
  void initialize({String? endpoint}) {
    if (_isInitialized) return;

    final httpLink = HttpLink(
      endpoint ?? 'https://api.highaspirationskc.org/graphql',
    );

    final authLink = AuthLink(
      getToken: () async => _authToken != null ? 'Bearer $_authToken' : null,
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(cache: GraphQLCache(), link: link);
    _isInitialized = true;
  }

  /// Get the current GraphQL client instance
  GraphQLClient get client {
    if (!_isInitialized) {
      throw StateError(
        'GraphQLClientService must be initialized before use. '
        'Call GraphQLClientService.instance.initialize() first.',
      );
    }
    return _client!;
  }

  /// Set the authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get the current authentication token
  String? get authToken => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  /// Clear the authentication token
  void clearAuthToken() {
    _authToken = null;
  }
}
