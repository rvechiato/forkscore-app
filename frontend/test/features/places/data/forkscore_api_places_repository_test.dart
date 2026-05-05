import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/places/data/forkscore_api_places_repository.dart';
import 'package:forkscore_frontend/shared/http/simple_http_client.dart';

void main() {
  group('ForkScoreApiPlacesRepository', () {
    test('lista places com resumo compacto de reviews', () async {
      final client = _FakeHttpClient(
        getHandler: (uri, headers) async {
          expect(uri.toString(), 'https://api.example.com/places');
          expect(headers['authorization'], 'Bearer token-123');
          return const HttpResponseData(
            statusCode: 200,
            body:
                '[{"id":"place-1","name":"Cafe do Centro","neighborhood":"Centro","city":"Curitiba","latitude":-25.4284,"longitude":-49.2733,"category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub","category_id":"cat","name":"Cafeteria","slug":"cafeteria"},"created_by":{"id":"user-1","name":"Rafa"},"review_summary":{"total_reviews":2,"average_rating":4.3}},{"id":"place-2","name":"Padaria da Vila","neighborhood":"Vila Nova","city":"Joinville","latitude":null,"longitude":null,"category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub-padaria","category_id":"cat","name":"Padaria Gourmet","slug":"padaria-gourmet"},"created_by":{"id":"user-2","name":"Pat"},"review_summary":{"total_reviews":0,"average_rating":null}}]',
          );
        },
      );
      final repository = ForkScoreApiPlacesRepository(
        baseUrl: 'https://api.example.com',
        client: client,
      );

      final places = await repository.listPlaces(accessToken: 'token-123');

      expect(places, hasLength(2));
      expect(places.first.instagramUrl, isNull);
      expect(places.first.latitude, -25.4284);
      expect(places.first.longitude, -49.2733);
      expect(places.first.hasLocation, isTrue);
      expect(places.last.hasLocation, isFalse);
      expect(places.first.reviewSummary.totalReviews, 2);
      expect(places.first.reviewSummary.averageRating, 4.3);
      expect(places.last.reviewSummary.totalReviews, 0);
      expect(places.last.reviewSummary.averageRating, isNull);
    });

    test(
      'cria place enviando link opcional do Instagram e coordenadas',
      () async {
        final client = _FakeHttpClient(
          postHandler: (uri, headers, body) async {
            expect(uri.toString(), 'https://api.example.com/places');
            expect(headers['authorization'], 'Bearer token-123');
            final payload = jsonDecode(body!) as Map<String, dynamic>;
            expect(
              payload['instagram_url'],
              'https://www.instagram.com/cafedocentro',
            );
            expect(payload['latitude'], -25.4284);
            expect(payload['longitude'], -49.2733);
            return const HttpResponseData(
              statusCode: 201,
              body:
                  '{"id":"place-1","name":"Cafe do Centro","street":"Rua das Flores","number":"123","neighborhood":"Centro","city":"Curitiba","instagram_url":"https://www.instagram.com/cafedocentro","latitude":-25.4284,"longitude":-49.2733,"category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub","category_id":"cat","name":"Cafeteria","slug":"cafeteria"},"created_by":{"id":"user-1","name":"Rafa"}}',
            );
          },
        );
        final repository = ForkScoreApiPlacesRepository(
          baseUrl: 'https://api.example.com',
          client: client,
        );

        final place = await repository.createPlace(
          accessToken: 'token-123',
          name: 'Cafe do Centro',
          street: 'Rua das Flores',
          number: '123',
          neighborhood: 'Centro',
          city: 'Curitiba',
          instagramUrl: 'https://www.instagram.com/cafedocentro',
          categoryId: 'cat',
          subcategoryId: 'sub',
          latitude: -25.4284,
          longitude: -49.2733,
        );

        expect(place.instagramUrl, 'https://www.instagram.com/cafedocentro');
        expect(place.latitude, -25.4284);
        expect(place.longitude, -49.2733);
        expect(place.hasLocation, isTrue);
      },
    );

    test('omite coordenadas do payload quando nao foram definidas', () async {
      final client = _FakeHttpClient(
        postHandler: (uri, headers, body) async {
          final payload = jsonDecode(body!) as Map<String, dynamic>;
          expect(payload.containsKey('latitude'), isFalse);
          expect(payload.containsKey('longitude'), isFalse);
          return const HttpResponseData(
            statusCode: 201,
            body:
                '{"id":"place-1","name":"Cafe do Centro","street":"Rua das Flores","number":"123","neighborhood":"Centro","city":"Curitiba","instagram_url":null,"latitude":null,"longitude":null,"category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub","category_id":"cat","name":"Cafeteria","slug":"cafeteria"},"created_by":{"id":"user-1","name":"Rafa"}}',
          );
        },
      );
      final repository = ForkScoreApiPlacesRepository(
        baseUrl: 'https://api.example.com',
        client: client,
      );

      final place = await repository.createPlace(
        accessToken: 'token-123',
        name: 'Cafe do Centro',
        street: 'Rua das Flores',
        number: '123',
        neighborhood: 'Centro',
        city: 'Curitiba',
        categoryId: 'cat',
        subcategoryId: 'sub',
      );

      expect(place.hasLocation, isFalse);
    });
  });
}

class _FakeHttpClient implements SimpleHttpClient {
  _FakeHttpClient({this.getHandler, this.postHandler});

  final Future<HttpResponseData> Function(Uri, Map<String, String>)? getHandler;
  final Future<HttpResponseData> Function(Uri, Map<String, String>, String?)?
  postHandler;

  @override
  Future<HttpResponseData> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) {
    final handler = getHandler;
    if (handler == null) {
      throw UnimplementedError();
    }
    return handler(uri, headers);
  }

  @override
  Future<HttpResponseData> post(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    final handler = postHandler;
    if (handler == null) {
      throw UnimplementedError();
    }
    return handler(uri, headers, body);
  }

  @override
  Future<HttpResponseData> put(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    throw UnimplementedError();
  }
}
