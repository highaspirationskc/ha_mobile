// lib/data/graphql/documents/mutations/create_grade_card_mutation.dart

/// GraphQL mutation to create a new grade card for a mentee
const String createGradeCardMutation = r'''
  mutation CreateGradeCard($input: CreateGradeCardInput!) {
    createGradeCard(input: $input) {
      gradeCard {
        id
        imageUrl
        thumbnailUrl
        description
        createdAt
        updatedAt
      }
      errors
    }
  }
''';
