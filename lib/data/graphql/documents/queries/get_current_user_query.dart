// lib/data/graphql/documents/queries/get_current_user_query.dart

/// GraphQL query to fetch the currently authenticated user
const String getCurrentUserQuery = r'''
  query GetCurrentUser {
    currentUser {
      id
      email
      firstName
      lastName
      phoneNumber
      avatarUrl
      role
      mentee {
        id
        mentor {
          id
          user {
            id
            firstName
            lastName
            email
            phoneNumber
            avatarUrl
          }
        }
        guardians {
          id
          user {
            id
            firstName
            lastName
            email
            phoneNumber
            avatarUrl
          }
        }
      }
      guardian {
        id
        children {
          id
          user {
            id
            firstName
            lastName
            email
            phoneNumber
            avatarUrl
          }
        }
      }
    }
  }
''';
