// lib/data/graphql/documents/mutations/delete_grade_card_mutation.dart

/// GraphQL mutation to delete a grade card
const String deleteGradeCardMutation = r'''
  mutation DeleteGradeCard($id: ID!) {
    deleteGradeCard(id: $id) {
      success
      errors
    }
  }
''';
