// lib/data/graphql/documents/queries/get_mentees_by_mentor_query.dart

/// GraphQL query to fetch mentees assigned to a specific mentor
const String getMenteesByMentorQuery = r'''
  query GetMenteesByMentor($mentorId: ID!) {
    menteesByMentor(mentorId: $mentorId) {
      id
      email
      firstName
      lastName
      phone
      image
      colorIndex
    }
  }
''';
