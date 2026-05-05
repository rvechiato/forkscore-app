import 'models/place_location_suggestion.dart';

abstract class PlaceLocationSearchRepository {
  Future<List<PlaceLocationSuggestion>> searchByAddress({
    required String street,
    required String number,
    required String neighborhood,
    required String city,
  });
}

class PlaceLocationSearchException implements Exception {
  const PlaceLocationSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}
