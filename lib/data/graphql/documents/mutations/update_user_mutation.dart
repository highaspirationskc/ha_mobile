// lib/data/graphql/documents/mutations/update_user_mutation.dart

/// GraphQL mutation to update user profile (including avatar)
const String updateUserMutation = r'''
  mutation UpdateUser($input: UpdateUserInput!) {
    updateUser(input: $input) {
      user {
        id
        avatarUrl
      }
      errors
    }
  }
''';
