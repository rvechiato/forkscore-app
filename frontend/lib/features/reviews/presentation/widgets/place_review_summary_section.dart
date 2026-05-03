import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/models/place_review_summary.dart';
import '../../domain/reviews_repository.dart';
import '../controllers/place_review_summary_controller.dart';

class PlaceReviewSummarySection extends StatefulWidget {
  const PlaceReviewSummarySection({
    super.key,
    required this.placeId,
    required this.repository,
    required this.accessTokenProvider,
  });

  final String placeId;
  final ReviewsRepository repository;
  final String? Function() accessTokenProvider;

  @override
  State<PlaceReviewSummarySection> createState() =>
      _PlaceReviewSummarySectionState();
}

class _PlaceReviewSummarySectionState extends State<PlaceReviewSummarySection> {
  late final PlaceReviewSummaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlaceReviewSummaryController(
      repository: widget.repository,
      accessTokenProvider: widget.accessTokenProvider,
    );
    _controller.load(widget.placeId);
  }

  @override
  void didUpdateWidget(covariant PlaceReviewSummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _controller.load(widget.placeId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return _LoadingReviewSummary(theme: theme);
          }

          if (_controller.errorMessage case final message?) {
            return _ErrorReviewSummary(
              theme: theme,
              message: message,
              onRetry: _controller.retry,
            );
          }

          final summary = _controller.summary;
          if (summary == null || !summary.hasReviews) {
            return _EmptyReviewSummary(theme: theme);
          }

          return _ReviewSummaryContent(theme: theme, summary: summary);
        },
      ),
    );
  }
}

class _LoadingReviewSummary extends StatelessWidget {
  const _LoadingReviewSummary({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('place-review-summary-loading'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(theme: theme),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Carregando o resumo de reviews deste local...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorReviewSummary extends StatelessWidget {
  const _ErrorReviewSummary({
    required this.theme,
    required this.message,
    required this.onRetry,
  });

  final ThemeData theme;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('place-review-summary-error'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(theme: theme),
        const SizedBox(height: 14),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8D3F2B),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('place-review-summary-retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}

class _EmptyReviewSummary extends StatelessWidget {
  const _EmptyReviewSummary({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('place-review-summary-empty'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(theme: theme),
        const SizedBox(height: 12),
        Text(
          'Ainda nao existem reviews para este local.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Se quiser, voce pode ser a primeira pessoa a registrar uma avaliacao.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ReviewSummaryContent extends StatelessWidget {
  const _ReviewSummaryContent({required this.theme, required this.summary});

  final ThemeData theme;
  final PlaceReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('place-review-summary-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(theme: theme),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFC57D10),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.averageRating?.toStringAsFixed(1) ?? '-',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${summary.totalReviews} review${summary.totalReviews == 1 ? '' : 's'} registradas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _CriteriaRatingsPanel(theme: theme, summary: summary),
        if (summary.recommendationSummary.hasReviews) ...[
          const SizedBox(height: 18),
          _RecommendationBreakdownBar(
            theme: theme,
            summary: summary.recommendationSummary,
            totalReviews: summary.totalReviews,
          ),
        ],
      ],
    );
  }
}

class _CriteriaRatingsPanel extends StatelessWidget {
  const _CriteriaRatingsPanel({required this.theme, required this.summary});

  final ThemeData theme;
  final PlaceReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final ratingsByCode = {
      for (final rating in summary.criteriaRatings) rating.code: rating,
    };
    final ratings = PlaceReviewCriterionRatingCode.orderedValues
        .map((code) {
          return ratingsByCode[code] ??
              PlaceReviewCriterionRating(
                code: code,
                label: code.label,
                averageRating: null,
                totalReviews: 0,
              );
        })
        .toList(growable: false);

    return Column(
      key: const Key('place-review-criteria-ratings'),
      children: [
        for (final rating in ratings) ...[
          _CriterionRatingRow(theme: theme, rating: rating),
          if (rating != ratings.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CriterionRatingRow extends StatelessWidget {
  const _CriterionRatingRow({required this.theme, required this.rating});

  final ThemeData theme;
  final PlaceReviewCriterionRating rating;

  @override
  Widget build(BuildContext context) {
    final averageLabel = rating.averageRating?.toStringAsFixed(1) ?? '-';

    return Semantics(
      key: Key('place-review-criterion-semantics-${rating.code.apiValue}'),
      label:
          '${rating.label}: media $averageLabel de 5, ${_ReadOnlyStarRating.roundedStarsFor(rating.averageRating)} de 5 estrelas preenchidas',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final label = Text(
            rating.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          );
          final score = Text(
            averageLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          );
          final stars = _ReadOnlyStarRating(
            key: Key('place-review-stars-${rating.code.apiValue}'),
            rating: rating.averageRating,
            semanticLabel: '${rating.label}: $averageLabel de 5',
          );

          if (constraints.maxWidth < 430) {
            return Column(
              key: Key('place-review-criterion-${rating.code.apiValue}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [score, const SizedBox(width: 10), stars],
                ),
              ],
            );
          }

          return Row(
            key: Key('place-review-criterion-${rating.code.apiValue}'),
            children: [
              Expanded(child: label),
              score,
              const SizedBox(width: 10),
              stars,
            ],
          );
        },
      ),
    );
  }
}

class _ReadOnlyStarRating extends StatelessWidget {
  const _ReadOnlyStarRating({
    super.key,
    required this.rating,
    required this.semanticLabel,
  });

  final double? rating;
  final String semanticLabel;

  static const _filledColor = Color(0xFFE0A11B);
  static const _emptyColor = Color(0xFFD8D2CA);

  static int roundedStarsFor(double? rating) {
    if (rating == null) {
      return 0;
    }
    return rating.round().clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    final filledStars = roundedStarsFor(rating);

    return Semantics(
      label: semanticLabel,
      readOnly: true,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < 5; index++)
              Icon(
                Icons.star_rounded,
                key: Key('place-review-star-$index'),
                color: index < filledStars ? _filledColor : _emptyColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationBreakdownBar extends StatelessWidget {
  const _RecommendationBreakdownBar({
    required this.theme,
    required this.summary,
    required this.totalReviews,
  });

  final ThemeData theme;
  final PlaceReviewRecommendationSummary summary;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    final recommendedFlex = summary.recommendedCount;
    final notRecommendedFlex = summary.notRecommendedCount;

    return Semantics(
      label:
          'Recomendacao: ${summary.recommendedPercentage}% recomendado e ${summary.notRecommendedPercentage}% nao recomendado',
      child: Column(
        key: const Key('place-review-recommendation-breakdown'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Recomendacao',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${summary.recommendedPercentage}% recomendado',
                key: const Key('place-review-recommended-percentage'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF2E6B4A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${summary.notRecommendedPercentage}% nao',
                key: const Key('place-review-not-recommended-percentage'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB14A3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (recommendedFlex > 0)
                    Expanded(
                      flex: recommendedFlex,
                      child: const ColoredBox(
                        key: Key('place-review-recommended-bar'),
                        color: Color(0xFF4F9D69),
                      ),
                    ),
                  if (notRecommendedFlex > 0)
                    Expanded(
                      flex: notRecommendedFlex,
                      child: const ColoredBox(
                        key: Key('place-review-not-recommended-bar'),
                        color: Color(0xFFD45A49),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalReviews review${totalReviews == 1 ? '' : 's'} consideradas',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.reviews_outlined,
          size: 18,
          color: AppTheme.primaryBrand,
        ),
        const SizedBox(width: 8),
        Text('Reviews do local', style: theme.textTheme.titleMedium),
      ],
    );
  }
}
