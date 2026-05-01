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
                '[{"id":"place-1","name":"Cafe do Centro","neighborhood":"Centro","city":"Curitiba","category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub","category_id":"cat","name":"Cafeteria","slug":"cafeteria"},"created_by":{"id":"user-1","name":"Rafa"},"review_summary":{"total_reviews":2,"average_rating":4.3}},{"id":"place-2","name":"Padaria da Vila","neighborhood":"Vila Nova","city":"Joinville","category":{"id":"cat","name":"Cafeteria","slug":"cafeteria"},"subcategory":{"id":"sub-padaria","category_id":"cat","name":"Padaria Gourmet","slug":"padaria-gourmet"},"created_by":{"id":"user-2","name":"Pat"},"review_summary":{"total_reviews":0,"average_rating":null}}]',
          );
        },
      );
      final repository = ForkScoreApiPlacesRepository(
        baseUrl: 'https://api.example.com',
        client: client,
      );

      final places = await repository.listPlaces(accessToken: 'token-123');

      expect(places, hasLength(2));
      expect(places.first.reviewSummary.totalReviews, 2);
      expect(places.first.reviewSummary.averageRating, 4.3);
      expect(places.last.reviewSummary.totalReviews, 0);
      expect(places.last.reviewSummary.averageRating, isNull);
    });
  });
}

class _FakeHttpClient implements SimpleHttpClient {
  _FakeHttpClient({required this.getHandler});

  final Future<HttpResponseData> Function(Uri, Map<String, String>) getHandler;

  @override
  Future<HttpResponseData> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) {
    return getHandler(uri, headers);
  }

  @override
  Future<HttpResponseData> post(
    Uri uri, {
    Map<String, String> headers = const {},
    String? body,
  }) {
    throw UnimplementedError();
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
