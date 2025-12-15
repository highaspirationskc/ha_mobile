// lib/data/graphql/documents/mutations/compose_message_mutation.dart

/// GraphQL mutation to compose and send a new message
const String composeMessageMutation = r'''
  mutation ComposeMessage($input: ComposeMessageInput!) {
    composeMessage(input: $input) {
      message {
        id
        subject
        message
        createdAt
      }
      errors
    }
  }
''';
