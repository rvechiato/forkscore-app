import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/places/domain/models/place_create_request.dart';

void main() {
  group('PlaceCreateRequest', () {
    test(
      'serializa payload sem coordenadas quando localizacao esta ausente',
      () {
        const request = PlaceCreateRequest(
          name: 'Cafe do Centro',
          street: 'Rua das Flores',
          number: '123',
          neighborhood: 'Centro',
          city: 'Curitiba',
          instagramUrl: null,
          categoryId: 'cat',
          subcategoryId: 'sub',
        );

        final json = request.toJson();

        expect(json['instagram_url'], isNull);
        expect(json.containsKey('latitude'), isFalse);
        expect(json.containsKey('longitude'), isFalse);
      },
    );

    test('serializa latitude e longitude quando ambas estao definidas', () {
      const request = PlaceCreateRequest(
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

      final json = request.toJson();

      expect(json['latitude'], -25.4284);
      expect(json['longitude'], -49.2733);
    });
  });
}
