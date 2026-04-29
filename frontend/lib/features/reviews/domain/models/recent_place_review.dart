import 'recent_review_comment.dart';
import 'review_author.dart';
import 'review_criterion.dart';
import 'review_recommendation.dart';

class RecentPlaceReview {
  const RecentPlaceReview({
    required this.id,
    required this.author,
    required this.recommendation,
    required this.overallRating,
    required this.createdAt,
    required this.comments,
  });

  final String id;
  final ReviewAuthor author;
  final ReviewRecommendation recommendation;
  final double overallRating;
  final DateTime createdAt;
  final List<RecentReviewComment> comments;

  factory RecentPlaceReview.fromJson(Map<String, dynamic> payload) {
    return RecentPlaceReview(
      id: payload['id'] as String,
      author: ReviewAuthor.fromJson(payload['user'] as Map<String, dynamic>),
      recommendation: ReviewRecommendation.fromApiValue(
        payload['recommendation'] as String,
      ),
      overallRating: (payload['overall_rating'] as num).toDouble(),
      createdAt: DateTime.parse(payload['created_at'] as String),
      comments: (payload['criteria'] as List<dynamic>)
          .map(
            (item) => RecentReviewComment.fromReviewCriterion(
              ReviewCriterion.fromJson(item as Map<String, dynamic>),
            ),
          )
          .toList(growable: false),
    );
  }
}
