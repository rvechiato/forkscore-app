import 'place_author.dart';
import 'place_category.dart';
import 'place_subcategory.dart';

class PlaceDetail {
  const PlaceDetail({
    required this.id,
    required this.name,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    this.instagramUrl,
    this.latitude,
    this.longitude,
    required this.category,
    required this.subcategory,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String? instagramUrl;
  final double? latitude;
  final double? longitude;
  final PlaceCategory category;
  final PlaceSubcategory subcategory;
  final PlaceAuthor createdBy;

  bool get hasLocation => latitude != null && longitude != null;
}
