// lib/data/graphql/documents/mutations/create_redemption_mutation.dart

/// GraphQL mutation to redeem an incentive
const String createRedemptionMutation = r'''
  mutation CreateRedemption($incentiveId: ID!) {
    createRedemption(incentiveId: $incentiveId) {
      errors
      redemption {
        id
        pointsSpent
        status
        createdAt
        approvedAt
        notes
        incentive {
          id
          name
          description
          imageUrl
          incentiveType
          pointCost
          active
          createdAt
          updatedAt
        }
      }
    }
  }
''';
