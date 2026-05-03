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
  testWidgets('renderiza ratings por criterio e remove comentarios recentes', (
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
              criteriaRatings: const [
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.taste,
                  label: 'Sabor',
                  averageRating: 4.4,
                  totalReviews: 2,
                ),
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.service,
                  label: 'Atendimento',
                  averageRating: 4.5,
                  totalReviews: 2,
                ),
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.options,
                  label: 'Opcoes',
                  averageRating: 3.8,
                  totalReviews: 2,
                ),
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.infrastructure,
                  label: 'Infraestrutura',
                  averageRating: 4,
                  totalReviews: 2,
                ),
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.costBenefit,
                  label: 'Custo-beneficio',
                  averageRating: 3.7,
                  totalReviews: 2,
                ),
              ],
              recommendationSummary: PlaceReviewRecommendationSummary(
                recommendedCount: 1,
                notRecommendedCount: 1,
                recommendedPercentage: 50,
                notRecommendedPercentage: 50,
              ),
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
    expect(find.text('Sabor'), findsOneWidget);
    expect(find.text('Atendimento'), findsOneWidget);
    expect(find.text('Opcoes'), findsOneWidget);
    expect(find.text('Infraestrutura'), findsOneWidget);
    expect(find.text('Custo-beneficio'), findsOneWidget);
    expect(find.text('Comentarios recentes'), findsNothing);
    expect(find.text('Cafe equilibrado.'), findsNothing);
  });

  testWidgets('arredonda estrelas com regra comum e estrelas restantes cinza', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestHarness(
        child: PlaceReviewSummarySection(
          placeId: 'place-1',
          repository: _FakeReviewsRepository(
            summary: const PlaceReviewSummary(
              placeId: 'place-1',
              totalReviews: 2,
              averageRating: 4.5,
              criteriaRatings: [
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.taste,
                  label: 'Sabor',
                  averageRating: 4.4,
                  totalReviews: 2,
                ),
                PlaceReviewCriterionRating(
                  code: PlaceReviewCriterionRatingCode.service,
                  label: 'Atendimento',
                  averageRating: 4.5,
                  totalReviews: 2,
                ),
              ],
              recommendationSummary: PlaceReviewRecommendationSummary(
                recommendedCount: 2,
                notRecommendedCount: 0,
                recommendedPercentage: 100,
                notRecommendedPercentage: 0,
              ),
              recentReviews: [],
            ),
          ),
          accessTokenProvider: () => 'token-123',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tasteStars = find.descendant(
      of: find.byKey(const Key('place-review-stars-taste')),
      matching: find.byIcon(Icons.star_rounded),
    );
    final serviceStars = find.descendant(
      of: find.byKey(const Key('place-review-stars-service')),
      matching: find.byIcon(Icons.star_rounded),
    );

    expect(tasteStars, findsNWidgets(5));
    expect(serviceStars, findsNWidgets(5));
    expect(_iconColors(tester, tasteStars), const [
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFD8D2CA),
    ]);
    expect(_iconColors(tester, serviceStars), const [
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
      Color(0xFFE0A11B),
    ]);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const Key('place-review-criterion-semantics-taste')),
          )
          .properties
          .label,
      'Sabor: media 4.4 de 5, 4 de 5 estrelas preenchidas',
    );
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const Key('place-review-criterion-semantics-service')),
          )
          .properties
          .label,
      'Atendimento: media 4.5 de 5, 5 de 5 estrelas preenchidas',
    );
  });

  testWidgets('renderiza barra unica de recomendacao com percentuais', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _TestHarness(
        child: PlaceReviewSummarySection(
          placeId: 'place-1',
          repository: _FakeReviewsRepository(
            summary: const PlaceReviewSummary(
              placeId: 'place-1',
              totalReviews: 4,
              averageRating: 4.2,
              criteriaRatings: [],
              recommendationSummary: PlaceReviewRecommendationSummary(
                recommendedCount: 3,
                notRecommendedCount: 1,
                recommendedPercentage: 75,
                notRecommendedPercentage: 25,
              ),
              recentReviews: [],
            ),
          ),
          accessTokenProvider: () => 'token-123',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('place-review-recommendation-breakdown')),
      findsOneWidget,
    );
    expect(find.text('75% recomendado'), findsOneWidget);
    expect(find.text('25% nao'), findsOneWidget);
    expect(
      find.byKey(const Key('place-review-recommended-bar')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('place-review-not-recommended-bar')),
      findsOneWidget,
    );
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
    expect(find.text('Comentarios recentes'), findsNothing);
    expect(
      find.byKey(const Key('place-review-recommendation-breakdown')),
      findsNothing,
    );
    expect(find.textContaining('%'), findsNothing);
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

List<Color?> _iconColors(WidgetTester tester, Finder finder) {
  return tester.widgetList<Icon>(finder).map((icon) => icon.color).toList();
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

  @override
  Future<List<RecentPlaceReview>> listPlaceReviews({
    required String accessToken,
    required String placeId,
  }) {
    throw UnimplementedError();
  }
}
