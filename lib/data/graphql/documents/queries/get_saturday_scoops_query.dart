// lib/data/graphql/documents/queries/get_saturday_scoops_query.dart

/// GraphQL query to fetch Saturday Scoops
const String getSaturdayScoopsQuery = r'''
  query GetSaturdayScoops {
    saturdayScoops {
      id
      title
      author
      description
      imageUrl
      imageThumbnailUrl
      videoUrl
      videoEmbedUrl
      videoThumbnailUrl
      publishOn
      published
      createdAt
      updatedAt
    }
  }
''';
