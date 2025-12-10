const String getOlympicSeasonQuery = r'''
  query GetOlympicSeason($input: OlympicSeasonQueryInput) {
    olympicSeason(input: $input) {
      id
      name
      startMonth
      startDay
      endMonth
      endDay
      createdAt
      updatedAt
      events {
        id
        name
        eventDate
        description
        location
        imageUrl
        eventType {
          id
          name
        }
        registeredUsers {
          id
          firstName
          lastName
          avatarUrl
          role
        }
        arrivedUsers {
          id
          firstName
          lastName
          avatarUrl
          role
        }
        createdAt
        updatedAt
      }
    }
  }
''';
