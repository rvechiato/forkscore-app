import 'dart:convert';

import '../../../shared/http/simple_http_client.dart';
import '../domain/models/submitted_review.dart';
import '../domain/models/review_submission_request.dart';
import '../domain/reviews_repository.dart';

class ForkScoreApiReviewsRepository implements ReviewsRepository {
  ForkScoreApiReviewsRepository({
    required String baseUrl,
    SimpleHttpClient? client,
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? createPlatformHttpClient();

  final Uri _baseUri;
  final SimpleHttpClient _client;

  @override
  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  }) async {
    final response = await _client.post(
      _resolve('/places/$placeId/reviews'),
      headers: _authorizedHeaders(accessToken),
      body: jsonEncode(request.toJson()),
    );
    final body = _decodeBody(response);
    _ensureSuccess(response.statusCode, body);
    return SubmittedReview.fromJson(body);
  }

  Uri _resolve(String path) => _baseUri.resolve(path);

  Map<String, dynamic> _decodeBody(HttpResponseData response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _ensureSuccess(int statusCode, Map<String, dynamic> body) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final detail = body['detail'];
    if (detail is String && detail.isNotEmpty) {
      throw ReviewsRepositoryException(detail);
    }

    throw ReviewsRepositoryException('Nao foi possivel enviar a avaliacao.');
  }

  Map<String, String> get _jsonHeaders => const {
    'content-type': 'application/json',
    'accept': 'application/json',
  };

  Map<String, String> _authorizedHeaders(String accessToken) => {
    ..._jsonHeaders,
    'authorization': 'Bearer $accessToken',
  };
}
