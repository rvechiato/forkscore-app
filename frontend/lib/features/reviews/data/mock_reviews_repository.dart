import '../domain/models/place_review_summary.dart';
import '../domain/models/recent_place_review.dart';
import '../domain/models/recent_review_comment.dart';
import '../domain/models/review_author.dart';
import '../domain/models/review_criterion.dart';
import '../domain/models/review_criterion_code.dart';
import '../domain/models/review_submission_request.dart';
import '../domain/models/review_recommendation.dart';
import '../domain/models/submitted_review.dart';
import '../domain/reviews_repository.dart';

class MockReviewsRepository implements ReviewsRepository {
  MockReviewsRepository() {
    _seedReviews();
  }

  final List<SubmittedReview> _submittedReviews = <SubmittedReview>[];
  int _nextId = 1;

  @override
  Future<PlaceReviewSummary> getPlaceReviewSummary({
    required String accessToken,
    required String placeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final placeReviews =
        _submittedReviews
            .where((review) => review.placeId == placeId)
            .toList(growable: false)
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    if (placeReviews.isEmpty) {
      return PlaceReviewSummary(
        placeId: placeId,
        totalReviews: 0,
        averageRating: null,
        criteriaRatings: _emptyCriteriaRatings(),
        recommendationSummary: const PlaceReviewRecommendationSummary.empty(),
        recentReviews: const [],
      );
    }

    final averageRating =
        placeReviews
            .map(_overallRatingFor)
            .reduce((left, right) => left + right) /
        placeReviews.length;

    return PlaceReviewSummary(
      placeId: placeId,
      totalReviews: placeReviews.length,
      averageRating: _roundToSingleDecimal(averageRating),
      criteriaRatings: _criteriaRatingsFor(placeReviews),
      recommendationSummary: _recommendationSummaryFor(placeReviews),
      recentReviews: placeReviews
          .take(3)
          .map(_mapRecentReview)
          .toList(growable: false),
    );
  }

  @override
  Future<List<RecentPlaceReview>> listPlaceReviews({
    required String accessToken,
    required String placeId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final placeReviews =
        _submittedReviews
            .where((review) => review.placeId == placeId)
            .toList(growable: false)
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return placeReviews.map(_mapRecentReview).toList(growable: false);
  }

  @override
  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    _validateRequest(request);

    final review = SubmittedReview(
      id: 'rev_${_nextId++}',
      placeId: placeId,
      user: _authorFromToken(accessToken),
      recommendation: request.recommendation,
      costBenefitRating: request.costBenefitRating,
      criteria: request.criteria,
      createdAt: DateTime.now().toUtc(),
    );
    _submittedReviews.insert(0, review);
    return review;
  }

  void _validateRequest(ReviewSubmissionRequest request) {
    if (request.costBenefitRating < 1 || request.costBenefitRating > 5) {
      throw ReviewsRepositoryException(
        'Custo-beneficio deve ficar entre 1 e 5.',
      );
    }
    if (request.criteria.length != ReviewCriterionCode.orderedValues.length) {
      throw ReviewsRepositoryException(
        'A review precisa conter os 4 criterios obrigatorios.',
      );
    }

    final seenCodes = <ReviewCriterionCode>{};
    for (final criterion in request.criteria) {
      _validateCriterion(criterion);
      if (!seenCodes.add(criterion.code)) {
        throw ReviewsRepositoryException(
          'Cada criterio deve aparecer exatamente uma vez.',
        );
      }
    }

    if (seenCodes.length != ReviewCriterionCode.orderedValues.length) {
      throw ReviewsRepositoryException(
        'A review precisa conter todos os criterios obrigatorios.',
      );
    }
  }

  void _validateCriterion(ReviewCriterion criterion) {
    if (criterion.rating < 1 || criterion.rating > 5) {
      throw ReviewsRepositoryException(
        'A nota de ${criterion.code.label} deve ficar entre 1 e 5.',
      );
    }

    if (criterion.comment.trim().isEmpty) {
      throw ReviewsRepositoryException(
        'Comentario obrigatorio em ${criterion.code.label}.',
      );
    }

    if (criterion.comment.trim().length > 500) {
      throw ReviewsRepositoryException(
        'Comentario de ${criterion.code.label} excede o limite permitido.',
      );
    }

    final justification = criterion.justification?.trim();
    if (criterion.rating < 3 &&
        (justification == null || justification.isEmpty)) {
      throw ReviewsRepositoryException(
        'Justificativa obrigatoria quando ${criterion.code.label} ficar abaixo de 3.',
      );
    }

    if (justification != null && justification.length > 500) {
      throw ReviewsRepositoryException(
        'Justificativa de ${criterion.code.label} excede o limite permitido.',
      );
    }
  }

  ReviewAuthor _authorFromToken(String accessToken) {
    final userId = accessToken.replaceFirst('mock-token-', '');
    final knownNames = <String, String>{
      'user-1': 'Gastronomo',
      'user-2': 'Rafa Vecchiato',
    };

    return ReviewAuthor(id: userId, name: knownNames[userId] ?? 'Avaliador');
  }

  RecentPlaceReview _mapRecentReview(SubmittedReview review) {
    return RecentPlaceReview(
      id: review.id,
      author: review.user,
      recommendation: review.recommendation,
      overallRating: _roundToSingleDecimal(_overallRatingFor(review)),
      createdAt: review.createdAt,
      comments: review.criteria
          .map(
            (criterion) => RecentReviewComment(
              code: criterion.code,
              rating: criterion.rating,
              comment: criterion.comment,
            ),
          )
          .toList(growable: false),
    );
  }

  double _overallRatingFor(SubmittedReview review) {
    final criteriaTotal = review.criteria.fold<int>(
      0,
      (sum, criterion) => sum + criterion.rating,
    );
    return (criteriaTotal + review.costBenefitRating) / 5;
  }

  List<PlaceReviewCriterionRating> _emptyCriteriaRatings() {
    return PlaceReviewCriterionRatingCode.orderedValues
        .map(
          (code) => PlaceReviewCriterionRating(
            code: code,
            label: code.label,
            averageRating: null,
            totalReviews: 0,
          ),
        )
        .toList(growable: false);
  }

  List<PlaceReviewCriterionRating> _criteriaRatingsFor(
    List<SubmittedReview> reviews,
  ) {
    return PlaceReviewCriterionRatingCode.orderedValues
        .map((code) {
          final average = switch (code) {
            PlaceReviewCriterionRatingCode.costBenefit =>
              reviews
                      .map((review) => review.costBenefitRating)
                      .reduce((left, right) => left + right) /
                  reviews.length,
            _ =>
              reviews
                      .map(
                        (review) => review.criteria
                            .firstWhere(
                              (criterion) =>
                                  criterion.code.apiValue == code.apiValue,
                            )
                            .rating,
                      )
                      .reduce((left, right) => left + right) /
                  reviews.length,
          };

          return PlaceReviewCriterionRating(
            code: code,
            label: code.label,
            averageRating: _roundToSingleDecimal(average),
            totalReviews: reviews.length,
          );
        })
        .toList(growable: false);
  }

  PlaceReviewRecommendationSummary _recommendationSummaryFor(
    List<SubmittedReview> reviews,
  ) {
    final recommendedCount = reviews
        .where(
          (review) => review.recommendation == ReviewRecommendation.recommended,
        )
        .length;
    final notRecommendedCount = reviews.length - recommendedCount;
    final recommendedPercentage = (recommendedCount * 100 / reviews.length)
        .round();

    return PlaceReviewRecommendationSummary(
      recommendedCount: recommendedCount,
      notRecommendedCount: notRecommendedCount,
      recommendedPercentage: recommendedPercentage,
      notRecommendedPercentage: 100 - recommendedPercentage,
    );
  }

  double _roundToSingleDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  void _seedReviews() {
    _submittedReviews.addAll(<SubmittedReview>[
      SubmittedReview(
        id: 'rev_${_nextId++}',
        placeId: 'place-1',
        user: const ReviewAuthor(id: 'user-2', name: 'Rafa Vecchiato'),
        recommendation: ReviewRecommendation.recommended,
        costBenefitRating: 4,
        criteria: const [
          ReviewCriterion(
            code: ReviewCriterionCode.taste,
            rating: 5,
            comment: 'Cafe equilibrado e bem extraido.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.service,
            rating: 4,
            comment: 'Atendimento agil no balcao.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.options,
            rating: 4,
            comment: 'Boas opcoes de graos e acompanhamentos.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.infrastructure,
            rating: 4,
            comment: 'Sala compacta, mas confortavel para uma pausa curta.',
          ),
        ],
        createdAt: DateTime.utc(2026, 4, 27, 14, 30),
      ),
      SubmittedReview(
        id: 'rev_${_nextId++}',
        placeId: 'place-1',
        user: const ReviewAuthor(id: 'user-1', name: 'Gastronomo'),
        recommendation: ReviewRecommendation.recommended,
        costBenefitRating: 5,
        criteria: const [
          ReviewCriterion(
            code: ReviewCriterionCode.taste,
            rating: 4,
            comment: 'Doce na medida e boa finalizacao.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.service,
            rating: 5,
            comment: 'Equipe simpática e proativa.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.options,
            rating: 4,
            comment: 'Vitrine enxuta, mas com variedade suficiente.',
          ),
          ReviewCriterion(
            code: ReviewCriterionCode.infrastructure,
            rating: 4,
            comment: 'Mesas bem distribuidas e ambiente claro.',
          ),
        ],
        createdAt: DateTime.utc(2026, 4, 25, 10, 15),
      ),
    ]);
  }
}
