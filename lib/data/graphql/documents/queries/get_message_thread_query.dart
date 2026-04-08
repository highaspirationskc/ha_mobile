// lib/data/graphql/documents/queries/get_message_thread_query.dart

/// GraphQL query to fetch a message thread and mark it as read
const String getMessageThreadQuery = r'''
  query GetMessageThread($messageId: ID!) {
    messageThread(messageId: $messageId) {
      id
      subject
      message
      isRead
      isReply
      replyMode
      support
      createdAt
      updatedAt
      recipients {
        id
        firstName
        lastName
        email
        avatarUrl
      }
      replies {
        id
        subject
        message
        isRead
        isReply
        createdAt
      }
      parent {
        id
        subject
      }
      threadRoot {
        id
        subject
      }
    }
  }
''';
