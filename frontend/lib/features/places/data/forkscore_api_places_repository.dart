import 'dart:convert';

import '../../../shared/http/simple_http_client.dart';
import '../domain/models/place_author.dart';
import '../domain/models/place_detail.dart';
import '../domain/models/place_summary.dart';
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
  Future<List<PlaceSummary>> listPlaces({
    required String accessToken,
  }) async {
    final response = await _client.get(
      _resolve('/places'),
      headers: _authorizedHeaders(accessToken),
    );
    final body = _decodeBody(response);
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
      }),
    );
    final body = _decodeMapBody(response);
    _ensureSuccess(response.statusCode, body);
    return _parsePlaceDetail(body);
  }

  Uri _resolve(String path) => _baseUri.resolve(path);

  List<dynamic> _decodeBody(HttpResponseData response) {
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
      createdBy: _parseAuthor(payload['created_by'] as Map<String, dynamic>),
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
      createdBy: _parseAuthor(payload['created_by'] as Map<String, dynamic>),
    );
  }

  PlaceAuthor _parseAuthor(Map<String, dynamic> payload) {
    return PlaceAuthor(
      id: payload['id'] as String,
      name: payload['name'] as String?,
    );
  }

  void _ensureSuccess(int statusCode, Object body) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    if (body case {'detail': final String detail} when detail.isNotEmpty) {
      throw PlacesRepositoryException(detail);
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
