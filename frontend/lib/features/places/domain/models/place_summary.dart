import 'place_author.dart';
import 'place_category.dart';
import 'place_review_summary_brief.dart';
import 'place_subcategory.dart';

class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.neighborhood,
    required this.city,
    this.instagramUrl,
    this.latitude,
    this.longitude,
    required this.category,
    required this.subcategory,
    required this.createdBy,
    required this.reviewSummary,
  });

  final String id;
  final String name;
  final String neighborhood;
  final String city;
  final String? instagramUrl;
  final double? latitude;
  final double? longitude;
  final PlaceCategory category;
  final PlaceSubcategory subcategory;
  final PlaceAuthor createdBy;
  final PlaceReviewSummaryBrief reviewSummary;

  bool get hasLocation => latitude != null && longitude != null;
}
