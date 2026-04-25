import 'place_author.dart';

class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.city,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String neighborhood;
  final String city;
  final PlaceAuthor createdBy;
}
