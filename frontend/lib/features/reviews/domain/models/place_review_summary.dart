import 'recent_place_review.dart';

class PlaceReviewSummary {
  const PlaceReviewSummary({
    required this.placeId,
    required this.totalReviews,
    required this.averageRating,
    this.criteriaRatings = const [],
    this.recommendationSummary = const PlaceReviewRecommendationSummary.empty(),
    this.recentReviews = const [],
  });

  final String placeId;
  final int totalReviews;
  final double? averageRating;
  final List<RecentPlaceReview> recentReviews;
  final List<PlaceReviewCriterionRating> criteriaRatings;
  final PlaceReviewRecommendationSummary recommendationSummary;

  bool get hasReviews => totalReviews > 0;

  factory PlaceReviewSummary.fromJson(Map<String, dynamic> payload) {
    return PlaceReviewSummary(
      placeId: payload['place_id'] as String,
      totalReviews: payload['total_reviews'] as int,
      averageRating: (payload['average_rating'] as num?)?.toDouble(),
      criteriaRatings:
          (payload['criteria_ratings'] as List<dynamic>? ?? const [])
              .map(
                (item) => PlaceReviewCriterionRating.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(growable: false),
      recommendationSummary: switch (payload['recommendation_summary']) {
        final Map<String, dynamic> item =>
          PlaceReviewRecommendationSummary.fromJson(item),
        _ => const PlaceReviewRecommendationSummary.empty(),
      },
      recentReviews: (payload['recent_reviews'] as List<dynamic>? ?? const [])
          .map(
            (item) => RecentPlaceReview.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

class PlaceReviewCriterionRating {
  const PlaceReviewCriterionRating({
    required this.code,
    required this.label,
    required this.averageRating,
    required this.totalReviews,
  });

  final PlaceReviewCriterionRatingCode code;
  final String label;
  final double? averageRating;
  final int totalReviews;

  bool get hasReviews => totalReviews > 0 && averageRating != null;

  factory PlaceReviewCriterionRating.fromJson(Map<String, dynamic> payload) {
    final code = PlaceReviewCriterionRatingCode.fromApiValue(
      payload['code'] as String,
    );
    return PlaceReviewCriterionRating(
      code: code,
      label: payload['label'] as String? ?? code.label,
      averageRating: (payload['average_rating'] as num?)?.toDouble(),
      totalReviews: payload['total_reviews'] as int,
    );
  }
}

enum PlaceReviewCriterionRatingCode {
  taste(apiValue: 'taste', label: 'Sabor'),
  service(apiValue: 'service', label: 'Atendimento'),
  options(apiValue: 'options', label: 'Opcoes'),
  infrastructure(apiValue: 'infrastructure', label: 'Infraestrutura'),
  costBenefit(apiValue: 'cost_benefit', label: 'Custo-beneficio');

  const PlaceReviewCriterionRatingCode({
    required this.apiValue,
    required this.label,
  });

  final String apiValue;
  final String label;

  static const orderedValues = <PlaceReviewCriterionRatingCode>[
    PlaceReviewCriterionRatingCode.taste,
    PlaceReviewCriterionRatingCode.service,
    PlaceReviewCriterionRatingCode.options,
    PlaceReviewCriterionRatingCode.infrastructure,
    PlaceReviewCriterionRatingCode.costBenefit,
  ];

  static PlaceReviewCriterionRatingCode fromApiValue(String value) {
    return PlaceReviewCriterionRatingCode.values.firstWhere(
      (item) => item.apiValue == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Criterio invalido.'),
    );
  }
}

class PlaceReviewRecommendationSummary {
  const PlaceReviewRecommendationSummary({
    required this.recommendedCount,
    required this.notRecommendedCount,
    required this.recommendedPercentage,
    required this.notRecommendedPercentage,
  });

  const PlaceReviewRecommendationSummary.empty()
    : recommendedCount = 0,
      notRecommendedCount = 0,
      recommendedPercentage = 0,
      notRecommendedPercentage = 0;

  final int recommendedCount;
  final int notRecommendedCount;
  final int recommendedPercentage;
  final int notRecommendedPercentage;

  int get totalReviews => recommendedCount + notRecommendedCount;
  bool get hasReviews => totalReviews > 0;

  factory PlaceReviewRecommendationSummary.fromJson(
    Map<String, dynamic> payload,
  ) {
    return PlaceReviewRecommendationSummary(
      recommendedCount: payload['recommended_count'] as int,
      notRecommendedCount: payload['not_recommended_count'] as int,
      recommendedPercentage: payload['recommended_percentage'] as int,
      notRecommendedPercentage: payload['not_recommended_percentage'] as int,
    );
  }
}
