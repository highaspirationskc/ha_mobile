# GraphQL Structure

This directory contains the GraphQL client configuration and all GraphQL operations (queries and mutations).

## Directory Structure

```
graphql/
├── graphql_client.dart          # GraphQL client service singleton
└── documents/
    ├── mutations/
    │   ├── login_mutation.dart  # Login mutation
    │   └── mutations.dart       # Export file for all mutations
    └── queries/
        └── queries.dart         # Export file for all queries (add queries here)
```

## Usage

### GraphQL Client

The `GraphQLClientService` is a singleton that manages the GraphQL client instance and authentication token:

```dart
// Initialize the client (done automatically in ApiService)
GraphQLClientService.instance.initialize();

// Set auth token
GraphQLClientService.instance.setAuthToken('your-token');

// Get client for queries/mutations
final client = GraphQLClientService.instance.client;
```

### Adding New Mutations

1. Create a new file in `documents/mutations/`:
   ```dart
   // documents/mutations/create_user_mutation.dart
   const String createUserMutation = r'''
     mutation CreateUser($input: CreateUserInput!) {
       createUser(input: $input) {
         id
         name
       }
     }
   ''';
   ```

2. Export it in `documents/mutations/mutations.dart`:
   ```dart
   export 'login_mutation.dart';
   export 'create_user_mutation.dart';  // Add this line
   ```

3. Use it in your service:
   ```dart
   import '../graphql/documents/mutations/mutations.dart';
   
   final result = await GraphQLClientService.instance.client.mutate(
     MutationOptions(
       document: gql(createUserMutation),
       variables: {'input': {...}},
     ),
   );
   ```

### Adding New Queries

1. Create a new file in `documents/queries/`:
   ```dart
   // documents/queries/get_user_query.dart
   const String getUserQuery = r'''
     query GetUser($id: ID!) {
       user(id: $id) {
         id
         name
         email
       }
     }
   ''';
   ```

2. Export it in `documents/queries/queries.dart`:
   ```dart
   export 'get_user_query.dart';
   ```

3. Use it in your service:
   ```dart
   import '../graphql/documents/queries/queries.dart';
   
   final result = await GraphQLClientService.instance.client.query(
     QueryOptions(
       document: gql(getUserQuery),
       variables: {'id': userId},
     ),
   );
   ```

## Benefits of This Structure

1. **Separation of Concerns**: GraphQL operations are separate from business logic
2. **Reusability**: Mutations and queries can be reused across different services
3. **Maintainability**: Easy to find and update specific operations
4. **Type Safety**: Centralized location for all GraphQL strings
5. **Easy Imports**: Single import point for all mutations or queries

