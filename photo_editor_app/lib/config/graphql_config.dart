import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GraphQLConfig {
  static ValueNotifier<GraphQLClient> initializeClient() {
    // Per questo progetto demo, useremo una open GraphQL API
    // In un progetto reale, questo verrebbe da .env
    final String apiUrl = 'https://graphql-demo-api.herokuapp.com/graphql';
    
    final HttpLink httpLink = HttpLink(apiUrl);

    // Opzionale: Aggiungi autenticazione se necessario
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer <your-token>',
    );

    final Link link = authLink.concat(httpLink);

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}