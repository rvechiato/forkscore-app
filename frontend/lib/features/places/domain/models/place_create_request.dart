class PlaceCreateRequest {
  const PlaceCreateRequest({
    required this.name,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    this.instagramUrl,
    required this.categoryId,
    required this.subcategoryId,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String? instagramUrl;
  final String categoryId;
  final String subcategoryId;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'instagram_url': instagramUrl,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      if (latitude != null && longitude != null) ...{
        'latitude': latitude,
        'longitude': longitude,
      },
    };
  }
}
