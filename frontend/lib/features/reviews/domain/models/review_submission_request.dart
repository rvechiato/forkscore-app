import 'review_criterion.dart';
import 'review_recommendation.dart';

class ReviewSubmissionRequest {
  const ReviewSubmissionRequest({
    required this.recommendation,
    required this.costBenefitRating,
    required this.criteria,
  });

  final ReviewRecommendation recommendation;
  final int costBenefitRating;
  final List<ReviewCriterion> criteria;

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation.apiValue,
      'cost_benefit_rating': costBenefitRating,
      'criteria': criteria.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
