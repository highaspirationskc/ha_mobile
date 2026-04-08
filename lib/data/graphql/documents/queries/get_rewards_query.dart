// lib/data/graphql/documents/queries/get_rewards_query.dart

/// GraphQL query to fetch the current user's rewards data
const String getRewardsQuery = r'''
  query GetRewards {
    rewards {
      totalPoints
      individualIncentives {
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
      teamIncentives {
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
      redeemed {
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
