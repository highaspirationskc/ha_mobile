// lib/data/graphql/documents/queries/get_mentee_community_service_query.dart

/// GraphQL query to fetch a mentee's community service records and total hours
const String getMenteeCommunityServiceQuery = r'''
  query GetMenteeCommunityService($userId: ID!) {
    user(id: $userId) {
      id
      mentee {
        id
        totalCommunityServiceHours
        totalPoints
        communityServiceRecords {
          id
          event
          description
          eventDate
          hours
          approved
          createdAt
          updatedAt
        }
      }
    }
  }
''';
