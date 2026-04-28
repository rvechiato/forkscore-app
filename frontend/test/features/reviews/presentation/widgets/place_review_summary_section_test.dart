import 'package:flutter/material.dart';
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
import 'package:forkscore_frontend/features/reviews/presentation/widgets/place_review_summary_section.dart';
import 'package:forkscore_frontend/shared/theme/app_theme.dart';

void main() {
  testWidgets('renderiza resumo com media e comentarios recentes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestHarness(
        child: PlaceReviewSummarySection(
          placeId: 'place-1',
          repository: _FakeReviewsRepository(
            summary: PlaceReviewSummary(
              placeId: 'place-1',
              totalReviews: 2,
              averageRating: 4.2,
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
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('place-review-summary-content')),
      findsOneWidget,
    );
    expect(find.text('4.2'), findsOneWidget);
    expect(find.text('2 reviews registradas'), findsOneWidget);
    expect(find.text('Cafe equilibrado.'), findsOneWidget);
  });

  testWidgets('renderiza estado vazio sem quebrar o bloco', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestHarness(
        child: PlaceReviewSummarySection(
          placeId: 'place-2',
          repository: _FakeReviewsRepository(
            summary: const PlaceReviewSummary(
              placeId: 'place-2',
              totalReviews: 0,
              averageRating: null,
              recentReviews: [],
            ),
          ),
          accessTokenProvider: () => 'token-123',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-empty')), findsOneWidget);
    expect(
      find.text('Ainda nao existem reviews para este local.'),
      findsOneWidget,
    );
  });

  testWidgets('renderiza erro e permite retry', (WidgetTester tester) async {
    final repository = _FakeReviewsRepository(
      errorSequence: <Object?>[
        ReviewsRepositoryException('Falha ao ler reviews.'),
        const PlaceReviewSummary(
          placeId: 'place-1',
          totalReviews: 0,
          averageRating: null,
          recentReviews: [],
        ),
      ],
    );

    await tester.pumpWidget(
      _TestHarness(
        child: PlaceReviewSummarySection(
          placeId: 'place-1',
          repository: repository,
          accessTokenProvider: () => 'token-123',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-error')), findsOneWidget);
    expect(find.text('Falha ao ler reviews.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('place-review-summary-retry')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('place-review-summary-empty')), findsOneWidget);
    expect(repository.calls, 2);
  });
}

class _TestHarness extends StatelessWidget {
  const _TestHarness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: child),
    );
  }
}

class _FakeReviewsRepository implements ReviewsRepository {
  _FakeReviewsRepository({this.summary, this.errorSequence});

  final PlaceReviewSummary? summary;
  final List<Object?>? errorSequence;
  int calls = 0;

  @override
  Future<PlaceReviewSummary> getPlaceReviewSummary({
    required String accessToken,
    required String placeId,
  }) async {
    calls++;

    if (errorSequence case final sequence?) {
      final result = sequence[calls - 1];
      if (result is ReviewsRepositoryException) {
        throw result;
      }
      return result! as PlaceReviewSummary;
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
}
