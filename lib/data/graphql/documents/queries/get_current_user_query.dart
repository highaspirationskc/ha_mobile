// lib/data/graphql/documents/queries/get_current_user_query.dart

/// GraphQL query to fetch the currently authenticated user
const String getCurrentUserQuery = r'''
  query GetCurrentUser {
    currentUser {
      id
      email
      firstName
      lastName
      avatarUrl
      role
    }
  }
''';
