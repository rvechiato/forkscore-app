import 'dart:convert';

import '../../../shared/http/simple_http_client.dart';
import '../domain/models/place_author.dart';
import '../domain/models/place_category.dart';
import '../domain/models/place_detail.dart';
import '../domain/models/place_review_summary_brief.dart';
import '../domain/models/place_summary.dart';
import '../domain/models/place_subcategory.dart';
import '../domain/places_repository.dart';

class ForkScoreApiPlacesRepository implements PlacesRepository {
  ForkScoreApiPlacesRepository({
    required String baseUrl,
    SimpleHttpClient? client,
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? createPlatformHttpClient();

  final Uri _baseUri;
  final SimpleHttpClient _client;

  @override
  Future<List<PlaceCategory>> listCategories({
    required String accessToken,
  }) async {
    final response = await _client.get(
      _resolve('/places/categories'),
      headers: _authorizedHeaders(accessToken),
    );
    final body = _decodeListBody(response);
    _ensureSuccess(response.statusCode, body);

    return body
        .map((item) => _parseCategory(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<PlaceSubcategory>> listSubcategories({
    required String accessToken,
    required String categoryId,
  }) async {
    final response = await _client.get(
      _resolve('/places/categories/$categoryId/subcategories'),
      headers: _authorizedHeaders(accessToken),
    );
    final body = _decodeListBody(response);
    _ensureSuccess(response.statusCode, body);

    return body
        .map((item) => _parseSubcategory(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<PlaceSummary>> listPlaces({required String accessToken}) async {
    final response = await _client.get(
      _resolve('/places'),
      headers: _authorizedHeaders(accessToken),
    );
    final body = _decodeListBody(response);
    _ensureSuccess(response.statusCode, body);

    return body
        .map((item) => _parsePlaceSummary(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PlaceDetail> getPlaceById({
    required String accessToken,
    required String placeId,
  }) async {
    final response = await _client.get(
      _resolve('/places/$placeId'),
      headers: _authorizedHeaders(accessToken),
    );
    final body = _decodeMapBody(response);
    _ensureSuccess(response.statusCode, body);
    return _parsePlaceDetail(body);
  }

  @override
  Future<PlaceDetail> createPlace({
    required String accessToken,
    required String name,
    required String street,
    required String number,
    required String neighborhood,
    required String city,
    String? instagramUrl,
    required String categoryId,
    required String subcategoryId,
  }) async {
    final response = await _client.post(
      _resolve('/places'),
      headers: _authorizedHeaders(accessToken),
      body: jsonEncode({
        'name': name,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'instagram_url': instagramUrl,
        'category_id': categoryId,
        'subcategory_id': subcategoryId,
      }),
    );
    final body = _decodeMapBody(response);
    _ensureSuccess(response.statusCode, body);
    return _parsePlaceDetail(body);
  }

  Uri _resolve(String path) => _baseUri.resolve(path);

  List<dynamic> _decodeListBody(HttpResponseData response) {
    if (response.body.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      return [decoded];
    }
    return const [];
  }

  Map<String, dynamic> _decodeMapBody(HttpResponseData response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  PlaceSummary _parsePlaceSummary(Map<String, dynamic> payload) {
    return PlaceSummary(
      id: payload['id'] as String,
      name: payload['name'] as String,
      neighborhood: payload['neighborhood'] as String,
      city: payload['city'] as String,
      instagramUrl: payload['instagram_url'] as String?,
      category: _parseCategory(payload['category'] as Map<String, dynamic>),
      subcategory: _parseSubcategory(
        payload['subcategory'] as Map<String, dynamic>,
      ),
      createdBy: _parseAuthor(payload['created_by'] as Map<String, dynamic>),
      reviewSummary: _parseReviewSummary(
        payload['review_summary'] as Map<String, dynamic>,
      ),
    );
  }

  PlaceDetail _parsePlaceDetail(Map<String, dynamic> payload) {
    return PlaceDetail(
      id: payload['id'] as String,
      name: payload['name'] as String,
      street: payload['street'] as String,
      number: payload['number'] as String,
      neighborhood: payload['neighborhood'] as String,
      city: payload['city'] as String,
      instagramUrl: payload['instagram_url'] as String?,
      category: _parseCategory(payload['category'] as Map<String, dynamic>),
      subcategory: _parseSubcategory(
        payload['subcategory'] as Map<String, dynamic>,
      ),
      createdBy: _parseAuthor(payload['created_by'] as Map<String, dynamic>),
    );
  }

  PlaceCategory _parseCategory(Map<String, dynamic> payload) {
    return PlaceCategory(
      id: payload['id'] as String,
      name: payload['name'] as String,
      slug: payload['slug'] as String,
    );
  }

  PlaceSubcategory _parseSubcategory(Map<String, dynamic> payload) {
    return PlaceSubcategory(
      id: payload['id'] as String,
      categoryId: payload['category_id'] as String,
      name: payload['name'] as String,
      slug: payload['slug'] as String,
    );
  }

  PlaceAuthor _parseAuthor(Map<String, dynamic> payload) {
    return PlaceAuthor(
      id: payload['id'] as String,
      name: payload['name'] as String?,
    );
  }

  PlaceReviewSummaryBrief _parseReviewSummary(Map<String, dynamic> payload) {
    final averageRating = payload['average_rating'];
    return PlaceReviewSummaryBrief(
      totalReviews: payload['total_reviews'] as int,
      averageRating: averageRating == null
          ? null
          : (averageRating as num).toDouble(),
    );
  }

  void _ensureSuccess(int statusCode, Object body) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    if (body case {'detail': final String detail} when detail.isNotEmpty) {
      throw PlacesRepositoryException(detail);
    }
    if (body case [final Map<String, dynamic> first, ...]) {
      final detail = first['detail'];
      if (detail is String && detail.isNotEmpty) {
        throw PlacesRepositoryException(detail);
      }
    }

    throw PlacesRepositoryException('Nao foi possivel concluir a solicitacao.');
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

class PlacesRepositoryException implements Exception {
  PlacesRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
