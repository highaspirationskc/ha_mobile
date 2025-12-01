// lib/data/graphql/documents/mutations/logout_mutation.dart

/// GraphQL mutation for user logout
const String logoutMutation = r'''
  mutation Logout {
    logout {
      success
      message
    }
  }
''';
