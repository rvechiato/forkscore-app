import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/places/data/photon_place_location_search_repository.dart';
import 'package:forkscore_frontend/features/places/domain/place_location_search_repository.dart';
import 'package:forkscore_frontend/shared/http/simple_http_client.dart';

void main() {
  group('PhotonPlaceLocationSearchRepository', () {
    test('monta consulta de endereco e normaliza sugestoes', () async {
      final client = _FakeHttpClient(
        getHandler: (uri, headers) async {
          expect(uri.toString(), contains('https://photon.example.com/api/'));
          expect(
            uri.queryParameters['q'],
            'Rua das Flores, 123, Centro, Curitiba',
          );
          expect(uri.queryParameters['limit'], '3');
          expect(uri.queryParameters['lang'], 'pt');
          expect(headers['accept'], 'application/json');
          return const HttpResponseData(
            statusCode: 200,
            body:
                '{"features":[{"geometry":{"coordinates":[-49.2733,-25.4284]},"properties":{"name":"Cafe do Centro","street":"Rua das Flores","housenumber":"123","city":"Curitiba","state":"Parana"}}]}',
          );
        },
      );
      final repository = PhotonPlaceLocationSearchRepository(
        baseUrl: 'https://photon.example.com',
        client: client,
      );

      final suggestions = await repository.searchByAddress(
        street: 'Rua das Flores',
        number: '123',
        neighborhood: 'Centro',
        city: 'Curitiba',
      );

      expect(suggestions, hasLength(1));
      expect(suggestions.first.label, contains('Cafe do Centro'));
      expect(suggestions.first.latitude, -25.4284);
      expect(suggestions.first.longitude, -49.2733);
    });

    test('retorna lista vazia quando endereco ainda e insuficiente', () async {
      final repository = PhotonPlaceLocationSearchRepository(
        baseUrl: 'https://photon.example.com',
        client: _FakeHttpClient(),
      );

      final suggestions = await repository.searchByAddress(
        street: '',
        number: '',
        neighborhood: '',
        city: 'Curitiba',
      );

      expect(suggestions, isEmpty);
    });

    test('lança erro amigavel quando provider falha', () async {
      final client = _FakeHttpClient(
        getHandler: (_, _) async {
          return const HttpResponseData(statusCode: 500, body: '{}');
        },
      );
      final repository = PhotonPlaceLocationSearchRepository(
        baseUrl: 'https://photon.example.com',
        client: client,
      );

      expect(
        () => repository.searchByAddress(
          street: 'Rua das Flores',
          number: '123',
          neighborhood: 'Centro',
          city: 'Curitiba',
        ),
        throwsA(isA<PlaceLocationSearchException>()),
      );
    });
  });
}

class _FakeHttpClient implements SimpleHttpClient {
  _FakeHttpClient({this.getHandler});

  final Future<HttpResponseData> Function(Uri, Map<String, String>)? getHandler;

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
