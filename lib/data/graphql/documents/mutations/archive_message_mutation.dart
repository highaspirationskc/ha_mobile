// lib/data/graphql/documents/mutations/archive_message_mutation.dart

/// GraphQL mutation to archive or unarchive a message
const String archiveMessageMutation = r'''
  mutation ArchiveMessage($messageId: ID!, $archive: Boolean!) {
    archiveMessage(messageId: $messageId, archive: $archive) {
      success
      errors
    }
  }
''';
