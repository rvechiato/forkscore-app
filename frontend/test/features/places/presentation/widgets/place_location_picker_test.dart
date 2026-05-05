import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/places/domain/models/place_location_suggestion.dart';
import 'package:forkscore_frontend/features/places/domain/place_location_search_repository.dart';
import 'package:forkscore_frontend/features/places/presentation/widgets/place_location_picker.dart';
import 'package:forkscore_frontend/shared/theme/app_theme.dart';
import 'package:forkscore_frontend/shared/widgets/place_location_map.dart';

void main() {
  testWidgets('exibe estado vazio, estado marcado e limpa localizacao', (
    WidgetTester tester,
  ) async {
    double? latitude;
    double? longitude;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PlaceLocationPicker(
                latitude: latitude,
                longitude: longitude,
                street: 'Rua das Flores',
                number: '123',
                neighborhood: 'Centro',
                city: 'Curitiba',
                searchRepository: _FakeLocationSearchRepository(
                  suggestions: const [],
                ),
                onLocationChanged: (nextLatitude, nextLongitude) {
                  setState(() {
                    latitude = nextLatitude;
                    longitude = nextLongitude;
                  });
                },
                onClear: () {
                  setState(() {
                    latitude = null;
                    longitude = null;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('place-location-picker-empty')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('place-location-marker')), findsNothing);
    expect(find.byKey(const Key('place-location-clear-button')), findsNothing);

    tester
        .widget<PlaceLocationMap>(find.byType(PlaceLocationMap))
        .onLocationSelected!
        .call(-25.4284, -49.2733);
    await tester.pump();

    expect(
      find.byKey(const Key('place-location-picker-selected')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('place-location-marker')), findsOneWidget);
    expect(
      find.byKey(const Key('place-location-picker-coordinates')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('place-location-clear-button')));
    await tester.pump();

    expect(
      find.byKey(const Key('place-location-picker-empty')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('place-location-marker')), findsNothing);
  });

  testWidgets('busca endereco e posiciona marcador sugerido', (
    WidgetTester tester,
  ) async {
    double? latitude;
    double? longitude;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PlaceLocationPicker(
                latitude: latitude,
                longitude: longitude,
                street: 'Rua das Flores',
                number: '123',
                neighborhood: 'Centro',
                city: 'Curitiba',
                searchRepository: _FakeLocationSearchRepository(
                  suggestions: const [
                    PlaceLocationSuggestion(
                      label: 'Rua das Flores, 123, Curitiba',
                      latitude: -25.4284,
                      longitude: -49.2733,
                    ),
                  ],
                ),
                onLocationChanged: (nextLatitude, nextLongitude) {
                  setState(() {
                    latitude = nextLatitude;
                    longitude = nextLongitude;
                  });
                },
                onClear: () {},
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('place-location-search-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-location-marker')), findsOneWidget);
    expect(find.textContaining('Marcador sugerido'), findsOneWidget);
    expect(latitude, -25.4284);
    expect(longitude, -49.2733);
  });

  testWidgets('mostra mensagem quando endereco nao tem resultado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: PlaceLocationPicker(
            latitude: null,
            longitude: null,
            street: 'Rua inexistente',
            number: '0',
            neighborhood: 'Centro',
            city: 'Curitiba',
            searchRepository: _FakeLocationSearchRepository(
              suggestions: const [],
            ),
            onLocationChanged: (_, _) {},
            onClear: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('place-location-search-button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nao encontramos'), findsOneWidget);
    expect(find.byKey(const Key('place-location-marker')), findsNothing);
  });
}

class _FakeLocationSearchRepository implements PlaceLocationSearchRepository {
  const _FakeLocationSearchRepository({required this.suggestions});

  final List<PlaceLocationSuggestion> suggestions;

  @override
  Future<List<PlaceLocationSuggestion>> searchByAddress({
    required String street,
    required String number,
    required String neighborhood,
    required String city,
  }) async {
    return suggestions;
  }
}
