import 'models/place_detail.dart';
import 'models/place_category.dart';
import 'models/place_summary.dart';
import 'models/place_subcategory.dart';

abstract class PlacesRepository {
  Future<List<PlaceCategory>> listCategories({required String accessToken});

  Future<List<PlaceSubcategory>> listSubcategories({
    required String accessToken,
    required String categoryId,
  });

  Future<List<PlaceSummary>> listPlaces({required String accessToken});

  Future<PlaceDetail> getPlaceById({
    required String accessToken,
    required String placeId,
  });

  Future<PlaceDetail> createPlace({
    required String accessToken,
    required String name,
    required String street,
    required String number,
    required String neighborhood,
    required String city,
    String? instagramUrl,
    required String categoryId,
    required String subcategoryId,
    double? latitude,
    double? longitude,
  });
}
