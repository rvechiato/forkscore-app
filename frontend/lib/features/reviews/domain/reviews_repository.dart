import 'models/place_review_summary.dart';
import 'models/recent_place_review.dart';
import 'models/review_submission_request.dart';
import 'models/submitted_review.dart';

abstract class ReviewsRepository {
  Future<PlaceReviewSummary> getPlaceReviewSummary({
    required String accessToken,
    required String placeId,
  });

  Future<List<RecentPlaceReview>> listPlaceReviews({
    required String accessToken,
    required String placeId,
  });

  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  });
}

class ReviewsRepositoryException implements Exception {
  ReviewsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
