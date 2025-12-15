// lib/data/graphql/documents/queries/get_user_mentee_data_query.dart

/// GraphQL query to fetch a user's mentee data including guardians and mentor
const String getUserMenteeDataQuery = r'''
  query GetUserMenteeData($id: ID!) {
    user(id: $id) {
      id
      firstName
      lastName
      email
      avatarUrl
      mentee {
        id
        totalPoints
        totalCommunityServiceHours
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
      }
    }
  }
''';
