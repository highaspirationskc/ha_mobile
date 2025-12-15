// lib/data/graphql/documents/queries/get_teams_query.dart

/// GraphQL query to fetch all teams with their data
const String getTeamsQuery = r'''
  query GetTeams {
    teams {
      id
      name
      color
      totalPoints
      totalCommunityServiceHours
      mentors {
        id
        firstName
        lastName
        avatarUrl
      }
      mentees {
        id
        firstName
        lastName
        avatarUrl
      }
    }
  }
''';
