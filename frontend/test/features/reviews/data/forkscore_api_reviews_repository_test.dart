import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/reviews/data/forkscore_api_reviews_repository.dart';
import 'package:forkscore_frontend/features/reviews/domain/reviews_repository.dart';
import 'package:forkscore_frontend/shared/http/simple_http_client.dart';

void main() {
  group('ForkScoreApiReviewsRepository', () {
    test('carrega o resumo de reviews do local', () async {
      final client = _FakeHttpClient(
        getHandler: (uri, headers) async {
          expect(
            uri.toString(),
            'https://api.example.com/places/place-1/reviews/summary',
          );
          expect(headers['authorization'], 'Bearer token-123');
          return const HttpResponseData(
            statusCode: 200,
            body:
                '{"place_id":"place-1","total_reviews":2,"average_rating":4.2,"recent_reviews":[{"id":"rev-1","author":{"id":"user-1","name":"Rafa"},"recommendation":"recommended","overall_rating":4.4,"created_at":"2026-04-28T12:00:00Z","comments":[{"code":"taste","rating":5,"comment":"Cafe equilibrado."}]}]}',
          );
        },
      );
      final repository = ForkScoreApiReviewsRepository(
        baseUrl: 'https://api.example.com',
        client: client,
      );

      final summary = await repository.getPlaceReviewSummary(
        accessToken: 'token-123',
        placeId: 'place-1',
      );

      expect(summary.placeId, 'place-1');
      expect(summary.totalReviews, 2);
      expect(summary.averageRating, 4.2);
      expect(summary.recentReviews, hasLength(1));
      expect(summary.recentReviews.first.author.name, 'Rafa');
      expect(
        summary.recentReviews.first.comments.first.comment,
        'Cafe equilibrado.',
      );
    });

    test('propaga detalhe de erro da API', () async {
      final repository = ForkScoreApiReviewsRepository(
        baseUrl: 'https://api.example.com',
        client: _FakeHttpClient(
          getHandler: (uri, headers) async => const HttpResponseData(
            statusCode: 404,
            body: '{"detail":"Local nao encontrado."}',
          ),
        ),
      );

      expect(
        () => repository.getPlaceReviewSummary(
          accessToken: 'token-123',
          placeId: 'missing-place',
        ),
        throwsA(
          isA<ReviewsRepositoryException>().having(
            (error) => error.message,
            'message',
            'Local nao encontrado.',
          ),
        ),
      );
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
