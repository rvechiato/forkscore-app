import 'place_author.dart';

class PlaceDetail {
  const PlaceDetail({
    required this.id,
    required this.name,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final PlaceAuthor createdBy;
}
