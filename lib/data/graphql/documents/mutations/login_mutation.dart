// lib/data/graphql/documents/mutations/login_mutation.dart

/// GraphQL mutation for user login
const String loginMutation = r'''
  mutation Login($input: LoginInput!) {
    login(input: $input) {
      token
      user {
        id
        email
      }
    }
  }
''';
