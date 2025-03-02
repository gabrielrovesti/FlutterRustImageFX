import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLAPI {
  // Query per ottenere la collezione di immagini dell'utente
  static String getUserImagesQuery = r'''
    query GetUserImages {
      userImages {
        id
        title
        imageUrl
        createdAt
        filter
      }
    }
  ''';

  // Mutation per salvare un'immagine elaborata
  static String saveImageMutation = r'''
    mutation SaveImage($input: SaveImageInput!) {
      saveImage(input: $input) {
        id
        title
        imageUrl
        createdAt
        filter
      }
    }
  ''';

  // Mutation per eliminare un'immagine
  static String deleteImageMutation = r'''
    mutation DeleteImage($id: ID!) {
      deleteImage(id: $id) {
        success
        message
      }
    }
  ''';

  // Funzione per ottenere le immagini dell'utente
  static Future<List<dynamic>?> getUserImages(GraphQLClient client) async {
    final QueryOptions options = QueryOptions(
      document: gql(getUserImagesQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['userImages'];
  }

  // Funzione per salvare un'immagine elaborata
  static Future<Map<String, dynamic>?> saveImage(
    GraphQLClient client, {
    required String title,
    required String imageData,
    required String filter,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(saveImageMutation),
      variables: {
        'input': {
          'title': title,
          'imageData': imageData,
          'filter': filter,
        },
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['saveImage'];
  }

  // Funzione per eliminare un'immagine
  static Future<Map<String, dynamic>?> deleteImage(
    GraphQLClient client, {
    required String id,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(deleteImageMutation),
      variables: {
        'id': id,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result.data?['deleteImage'];
  }
}