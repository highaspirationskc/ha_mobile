// lib/data/graphql/documents/queries/get_inbox_query.dart

/// GraphQL query to fetch the current user's inbox messages
const String getInboxQuery = r'''
  query GetInbox {
    inbox {
      id
      subject
      message
      isReply
      replyMode
      support
      createdAt
      updatedAt
      author {
        id
        firstName
        lastName
        email
        avatarUrl
        role
      }
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
        createdAt
        author {
          id
          firstName
          lastName
          avatarUrl
        }
      }
    }
  }
''';
