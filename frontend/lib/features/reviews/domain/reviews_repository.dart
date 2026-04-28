import 'models/review_submission_request.dart';
import 'models/submitted_review.dart';

abstract class ReviewsRepository {
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
