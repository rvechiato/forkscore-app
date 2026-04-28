import 'review_criterion_code.dart';

class ReviewCriterion {
  const ReviewCriterion({
    required this.code,
    required this.rating,
    required this.comment,
    this.justification,
  });

  final ReviewCriterionCode code;
  final int rating;
  final String comment;
  final String? justification;

  Map<String, dynamic> toJson() {
    return {
      'code': code.apiValue,
      'rating': rating,
      'comment': comment,
      'justification': justification,
    };
  }

  factory ReviewCriterion.fromJson(Map<String, dynamic> payload) {
    return ReviewCriterion(
      code: ReviewCriterionCode.fromApiValue(payload['code'] as String),
      rating: payload['rating'] as int,
      comment: payload['comment'] as String,
      justification: payload['justification'] as String?,
    );
  }
}
