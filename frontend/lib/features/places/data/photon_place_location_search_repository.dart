import 'dart:convert';

import '../../../shared/http/simple_http_client.dart';
import '../domain/models/place_location_suggestion.dart';
import '../domain/place_location_search_repository.dart';

class PhotonPlaceLocationSearchRepository
    implements PlaceLocationSearchRepository {
  PhotonPlaceLocationSearchRepository({
    String baseUrl = 'https://photon.komoot.io',
    SimpleHttpClient? client,
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? createPlatformHttpClient();

  final Uri _baseUri;
  final SimpleHttpClient _client;

  @override
  Future<List<PlaceLocationSuggestion>> searchByAddress({
    required String street,
    required String number,
    required String neighborhood,
    required String city,
  }) async {
    final query = _buildQuery(
      street: street,
      number: number,
      neighborhood: neighborhood,
      city: city,
    );
    if (query == null) {
      return const [];
    }

    final uri = _baseUri.replace(
      path: '/api/',
      queryParameters: {'q': query, 'limit': '3', 'lang': 'pt'},
    );
    final response = await _client.get(uri, headers: _jsonHeaders);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const PlaceLocationSearchException(
        'Nao foi possivel localizar este endereco agora.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'];
    if (features is! List<dynamic>) {
      return const [];
    }

    return features
        .whereType<Map<String, dynamic>>()
        .map(_parseSuggestion)
        .whereType<PlaceLocationSuggestion>()
        .toList(growable: false);
  }

  PlaceLocationSuggestion? _parseSuggestion(Map<String, dynamic> feature) {
    final geometry = feature['geometry'];
    final properties = feature['properties'];
    if (geometry is! Map<String, dynamic> ||
        properties is! Map<String, dynamic>) {
      return null;
    }

    final coordinates = geometry['coordinates'];
    if (coordinates is! List<dynamic> || coordinates.length < 2) {
      return null;
    }

    final longitude = coordinates[0];
    final latitude = coordinates[1];
    if (latitude is! num || longitude is! num) {
      return null;
    }

    return PlaceLocationSuggestion(
      label: _labelFor(properties),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  String _labelFor(Map<String, dynamic> properties) {
    final parts = <String>[
      _stringValue(properties['name']),
      _stringValue(properties['street']),
      _stringValue(properties['housenumber']),
      _stringValue(properties['district']),
      _stringValue(properties['city']),
      _stringValue(properties['state']),
    ].where((part) => part.isNotEmpty).toList(growable: false);

    final uniqueParts = <String>[];
    for (final part in parts) {
      if (!uniqueParts.contains(part)) {
        uniqueParts.add(part);
      }
    }

    if (uniqueParts.isEmpty) {
      return 'Endereco encontrado';
    }
    return uniqueParts.join(', ');
  }

  String _stringValue(Object? value) {
    if (value is! String) {
      return '';
    }
    return value.trim();
  }

  String? _buildQuery({
    required String street,
    required String number,
    required String neighborhood,
    required String city,
  }) {
    final parts = [street, number, neighborhood, city]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (parts.length < 2) {
      return null;
    }
    return parts.join(', ');
  }

  Map<String, String> get _jsonHeaders => const {'accept': 'application/json'};
}
