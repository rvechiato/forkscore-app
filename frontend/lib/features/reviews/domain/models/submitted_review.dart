import 'review_author.dart';
import 'review_criterion.dart';
import 'review_recommendation.dart';

class SubmittedReview {
  const SubmittedReview({
    required this.id,
    required this.placeId,
    required this.user,
    required this.recommendation,
    required this.costBenefitRating,
    required this.criteria,
    required this.createdAt,
  });

  final String id;
  final String placeId;
  final ReviewAuthor user;
  final ReviewRecommendation recommendation;
  final int costBenefitRating;
  final List<ReviewCriterion> criteria;
  final DateTime createdAt;

  factory SubmittedReview.fromJson(Map<String, dynamic> payload) {
    return SubmittedReview(
      id: payload['id'] as String,
      placeId: payload['place_id'] as String,
      user: ReviewAuthor.fromJson(payload['user'] as Map<String, dynamic>),
      recommendation: ReviewRecommendation.fromApiValue(
        payload['recommendation'] as String,
      ),
      costBenefitRating: payload['cost_benefit_rating'] as int,
      criteria: (payload['criteria'] as List<dynamic>)
          .map(
            (item) => ReviewCriterion.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      createdAt: DateTime.parse(payload['created_at'] as String),
    );
  }
}
