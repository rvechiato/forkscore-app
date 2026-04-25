import 'models/place_detail.dart';
import 'models/place_summary.dart';

abstract class PlacesRepository {
  Future<List<PlaceSummary>> listPlaces({
    required String accessToken,
  });

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
  });
}
