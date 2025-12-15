// lib/data/graphql/documents/queries/get_mentees_by_mentor_query.dart

/// GraphQL query to fetch mentees assigned to a specific mentor
/// Uses the new user.mentor.mentees structure
const String getMenteesByMentorQuery = r'''
  query GetMenteesByMentor($mentorId: ID!) {
    user(id: $mentorId) {
      mentor {
        mentees {
          user {
            id
            email
            firstName
            lastName
            phoneNumber
            avatarUrl
            role
          }
        }
      }
    }
  }
''';
