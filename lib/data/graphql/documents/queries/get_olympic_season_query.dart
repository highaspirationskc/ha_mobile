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
          category
          pointValue
          createdAt
          updatedAt
        }
        registeredUsers {
          id
          firstName
          lastName
          email
          avatarUrl
          role
        }
        arrivedUsers {
          id
          firstName
          lastName
          email
          avatarUrl
          role
        }
        createdAt
        updatedAt
      }
    }
  }
''';
