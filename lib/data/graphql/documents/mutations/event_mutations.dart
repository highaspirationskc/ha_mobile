// lib/data/graphql/documents/mutations/event_mutations.dart

/// GraphQL mutation to register for an event
const String registerForEventMutation = r'''
  mutation Register($input: RegisterInput!) {
    register(input: $input) {
      eventLog {
        id
        logType
        pointsAwarded
      }
      errors
    }
  }
''';

/// GraphQL mutation to check in to an event
const String checkInToEventMutation = r'''
  mutation CheckIn($input: CheckInInput!) {
    checkIn(input: $input) {
      eventLog {
        id
        logType
        pointsAwarded
      }
      errors
    }
  }
''';
