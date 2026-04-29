import 'recent_place_review.dart';

class PlaceReviewSummary {
  const PlaceReviewSummary({
    required this.placeId,
    required this.totalReviews,
    required this.averageRating,
    required this.recentReviews,
  });

  final String placeId;
  final int totalReviews;
  final double? averageRating;
  final List<RecentPlaceReview> recentReviews;

  bool get hasReviews => totalReviews > 0;

  factory PlaceReviewSummary.fromJson(Map<String, dynamic> payload) {
    return PlaceReviewSummary(
      placeId: payload['place_id'] as String,
      totalReviews: payload['total_reviews'] as int,
      averageRating: (payload['average_rating'] as num?)?.toDouble(),
      recentReviews: (payload['recent_reviews'] as List<dynamic>)
          .map(
            (item) => RecentPlaceReview.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}
