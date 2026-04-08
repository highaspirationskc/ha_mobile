// lib/data/graphql/documents/queries/get_inbox_query.dart

/// GraphQL query to fetch the current user's inbox messages
const String getInboxQuery = r'''
  query GetInbox {
    inbox {
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
      parent {
        id
      }
      threadRoot {
        id
      }
      replies {
        id
        message
        isRead
        createdAt
      }
    }
  }
''';
