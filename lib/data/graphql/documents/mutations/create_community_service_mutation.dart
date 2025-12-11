// lib/data/graphql/documents/mutations/create_community_service_mutation.dart

/// GraphQL mutation to create a community service record
const String createCommunityServiceRecordMutation = r'''
  mutation CreateCommunityServiceRecord(
    $event: String!
    $description: String
    $eventDate: ISO8601Date!
    $hours: Float!
  ) {
    createCommunityServiceRecord(
      event: $event
      description: $description
      eventDate: $eventDate
      hours: $hours
    ) {
      communityServiceRecord {
        id
        event
        description
        eventDate
        hours
        approved
        createdAt
        updatedAt
      }
      errors
    }
  }
''';
