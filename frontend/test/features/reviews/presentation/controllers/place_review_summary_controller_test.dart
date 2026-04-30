import 'package:flutter_test/flutter_test.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/place_review_summary.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/recent_place_review.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/recent_review_comment.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/review_author.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/review_criterion_code.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/review_recommendation.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/review_submission_request.dart';
import 'package:forkscore_frontend/features/reviews/domain/models/submitted_review.dart';
import 'package:forkscore_frontend/features/reviews/domain/reviews_repository.dart';
import 'package:forkscore_frontend/features/reviews/presentation/controllers/place_review_summary_controller.dart';

void main() {
  group('PlaceReviewSummaryController', () {
    test('carrega resumo com sucesso', () async {
      final controller = PlaceReviewSummaryController(
        repository: _FakeReviewsRepository(
          summary: PlaceReviewSummary(
            placeId: 'place-1',
            totalReviews: 2,
            averageRating: 4.3,
            recentReviews: [
              RecentPlaceReview(
                id: 'rev-1',
                author: const ReviewAuthor(id: 'user-1', name: 'Rafa'),
                recommendation: ReviewRecommendation.recommended,
                overallRating: 4.4,
                createdAt: DateTime.utc(2026, 4, 28),
                comments: const [
                  RecentReviewComment(
                    code: ReviewCriterionCode.taste,
                    rating: 5,
                    comment: 'Cafe equilibrado.',
                  ),
                ],
              ),
            ],
          ),
        ),
        accessTokenProvider: () => 'token-123',
      );

      await controller.load('place-1');

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.summary?.placeId, 'place-1');
      expect(controller.summary?.averageRating, 4.3);
    });

    test('expõe erro de repositorio sem manter summary antiga', () async {
      final controller = PlaceReviewSummaryController(
        repository: _FakeReviewsRepository(
          error: ReviewsRepositoryException('Falha ao ler reviews.'),
        ),
        accessTokenProvider: () => 'token-123',
      );

      await controller.load('place-2');

      expect(controller.isLoading, isFalse);
      expect(controller.summary, isNull);
      expect(controller.errorMessage, 'Falha ao ler reviews.');
    });
  });
}

class _FakeReviewsRepository implements ReviewsRepository {
  _FakeReviewsRepository({this.summary, this.error});

  final PlaceReviewSummary? summary;
  final ReviewsRepositoryException? error;

  @override
  Future<PlaceReviewSummary> getPlaceReviewSummary({
    required String accessToken,
    required String placeId,
  }) async {
    if (error != null) {
      throw error!;
    }
    return summary!;
  }

  @override
  Future<SubmittedReview> submitReview({
    required String accessToken,
    required String placeId,
    required ReviewSubmissionRequest request,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<RecentPlaceReview>> listPlaceReviews({
    required String accessToken,
    required String placeId,
  }) {
    throw UnimplementedError();
  }
}
