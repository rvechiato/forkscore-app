import 'review_criterion.dart';
import 'review_criterion_code.dart';

class RecentReviewComment {
  const RecentReviewComment({
    required this.code,
    required this.rating,
    required this.comment,
  });

  final ReviewCriterionCode code;
  final int rating;
  final String comment;

  factory RecentReviewComment.fromJson(Map<String, dynamic> payload) {
    return RecentReviewComment(
      code: ReviewCriterionCode.fromApiValue(payload['code'] as String),
      rating: payload['rating'] as int,
      comment: payload['comment'] as String,
    );
  }

  factory RecentReviewComment.fromReviewCriterion(ReviewCriterion criterion) {
    return RecentReviewComment(
      code: criterion.code,
      rating: criterion.rating,
      comment: criterion.comment,
    );
  }
}
