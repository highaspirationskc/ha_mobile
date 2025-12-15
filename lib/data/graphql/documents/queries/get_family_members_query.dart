// lib/data/graphql/documents/queries/get_family_members_query.dart

/// GraphQL query to fetch all family member relationships
const String getFamilyMembersQuery = r'''
  query GetFamilyMembers {
    familyMembers {
      id
      relationshipType
      createdAt
      updatedAt
      user {
        id
        email
        firstName
        lastName
        phoneNumber
        avatarUrl
        role
      }
      relatedUser {
        id
        email
        firstName
        lastName
        phoneNumber
        avatarUrl
        role
      }
    }
  }
''';

/// GraphQL query to fetch a specific family member by ID
const String getFamilyMemberQuery = r'''
  query GetFamilyMember($id: ID!) {
    familyMember(id: $id) {
      id
      relationshipType
      createdAt
      updatedAt
      user {
        id
        email
        firstName
        lastName
        phoneNumber
        avatarUrl
        role
      }
      relatedUser {
        id
        email
        firstName
        lastName
        phoneNumber
        avatarUrl
        role
      }
    }
  }
''';
