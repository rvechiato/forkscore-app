import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/place_review_summary.dart';

void main() {
  group('PlaceReviewSummary', () {
    test('parseia payload expandido com criterios, recomendacao e reviews', () {
      final summary = PlaceReviewSummary.fromJson({
        'place_id': 'place-1',
        'total_reviews': 12,
        'average_rating': 4.2,
        'criteria_ratings': [
          {
            'code': 'taste',
            'label': 'Sabor',
            'average_rating': 4.6,
            'total_reviews': 12,
          },
          {
            'code': 'service',
            'label': 'Atendimento',
            'average_rating': 4.1,
            'total_reviews': 12,
          },
          {
            'code': 'options',
            'label': 'Opcoes',
            'average_rating': 3.8,
            'total_reviews': 12,
          },
          {
            'code': 'infrastructure',
            'label': 'Infraestrutura',
            'average_rating': 4.0,
            'total_reviews': 12,
          },
          {
            'code': 'cost_benefit',
            'label': 'Custo-beneficio',
            'average_rating': 3.7,
            'total_reviews': 12,
          },
        ],
        'recommendation_summary': {
          'recommended_count': 9,
          'not_recommended_count': 3,
          'recommended_percentage': 75,
          'not_recommended_percentage': 25,
        },
        'recent_reviews': [
          {
            'id': 'rev-1',
            'user': {'id': 'user-1', 'name': 'Rafa'},
            'recommendation': 'recommended',
            'overall_rating': 4.4,
            'created_at': '2026-04-28T12:00:00Z',
            'criteria': [
              {'code': 'taste', 'rating': 5, 'comment': 'Cafe equilibrado.'},
            ],
          },
        ],
      });

      expect(summary.placeId, 'place-1');
      expect(summary.totalReviews, 12);
      expect(summary.averageRating, 4.2);
      expect(summary.criteriaRatings, hasLength(5));
      expect(summary.criteriaRatings.map((rating) => rating.code.apiValue), [
        'taste',
        'service',
        'options',
        'infrastructure',
        'cost_benefit',
      ]);
      expect(summary.criteriaRatings.first.label, 'Sabor');
      expect(summary.criteriaRatings.first.averageRating, 4.6);
      expect(summary.criteriaRatings.last.averageRating, 3.7);
      expect(summary.recommendationSummary.recommendedCount, 9);
      expect(summary.recommendationSummary.notRecommendedCount, 3);
      expect(summary.recommendationSummary.recommendedPercentage, 75);
      expect(summary.recommendationSummary.notRecommendedPercentage, 25);
      expect(summary.recentReviews, hasLength(1));
      expect(summary.recentReviews.first.author.name, 'Rafa');
    });

    test(
      'mantem compatibilidade com payload antigo baseado em recent_reviews',
      () {
        final summary = PlaceReviewSummary.fromJson({
          'place_id': 'place-1',
          'total_reviews': 1,
          'average_rating': 4,
          'recent_reviews': [],
        });

        expect(summary.criteriaRatings, isEmpty);
        expect(summary.recommendationSummary.hasReviews, isFalse);
        expect(summary.recentReviews, isEmpty);
      },
    );

    test('parseia estado sem reviews com medias nulas', () {
      final summary = PlaceReviewSummary.fromJson({
        'place_id': 'place-empty',
        'total_reviews': 0,
        'average_rating': null,
        'criteria_ratings': [
          {
            'code': 'taste',
            'label': 'Sabor',
            'average_rating': null,
            'total_reviews': 0,
          },
          {
            'code': 'cost_benefit',
            'label': 'Custo-beneficio',
            'average_rating': null,
            'total_reviews': 0,
          },
        ],
        'recommendation_summary': {
          'recommended_count': 0,
          'not_recommended_count': 0,
          'recommended_percentage': 0,
          'not_recommended_percentage': 0,
        },
      });

      expect(summary.hasReviews, isFalse);
      expect(summary.averageRating, isNull);
      expect(summary.recentReviews, isEmpty);
      expect(summary.criteriaRatings, hasLength(2));
      expect(summary.criteriaRatings, everyElement(isNot(isNull)));
      expect(summary.criteriaRatings.first.averageRating, isNull);
      expect(summary.criteriaRatings.first.hasReviews, isFalse);
      expect(summary.recommendationSummary.totalReviews, 0);
      expect(summary.recommendationSummary.hasReviews, isFalse);
    });

    test('parseia resumo de recomendacao', () {
      final summary = PlaceReviewSummary.fromJson({
        'place_id': 'place-1',
        'total_reviews': 3,
        'average_rating': 4.1,
        'criteria_ratings': [],
        'recommendation_summary': {
          'recommended_count': 2,
          'not_recommended_count': 1,
          'recommended_percentage': 67,
          'not_recommended_percentage': 33,
        },
      });

      expect(summary.recommendationSummary.totalReviews, 3);
      expect(summary.recommendationSummary.hasReviews, isTrue);
      expect(summary.recommendationSummary.recommendedCount, 2);
      expect(summary.recommendationSummary.notRecommendedCount, 1);
      expect(summary.recommendationSummary.recommendedPercentage, 67);
      expect(summary.recommendationSummary.notRecommendedPercentage, 33);
    });
  });
}
