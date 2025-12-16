// lib/data/graphql/documents/mutations/reset_password_mutation.dart

/// GraphQL mutation to request a password reset
const String resetPasswordMutation = r'''
  mutation ResetPassword($email: String!) {
    resetPassword(email: $email) {
      success
      errors
    }
  }
''';
