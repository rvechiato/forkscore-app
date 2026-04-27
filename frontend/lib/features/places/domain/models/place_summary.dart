import 'place_author.dart';
import 'place_category.dart';
import 'place_subcategory.dart';

class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.city,
    required this.category,
    required this.subcategory,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String neighborhood;
  final String city;
  final PlaceCategory category;
  final PlaceSubcategory subcategory;
  final PlaceAuthor createdBy;
}
