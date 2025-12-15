// lib/data/graphql/documents/queries/get_mentee_grade_cards_query.dart

/// GraphQL query to fetch a mentee's grade cards
const String getMenteeGradeCardsQuery = r'''
  query GetMenteeGradeCards($userId: ID!) {
    user(id: $userId) {
      mentee {
        id
        gradeCards {
          id
          imageUrl
          thumbnailUrl
          description
          createdAt
          updatedAt
        }
      }
    }
  }
''';
