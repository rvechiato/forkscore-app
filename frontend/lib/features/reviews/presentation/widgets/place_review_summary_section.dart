import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/models/place_review_summary.dart';
import '../../domain/models/recent_place_review.dart';
import '../../domain/models/recent_review_comment.dart';
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
        Text(
          'Comentarios recentes',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        for (final review in summary.recentReviews) ...[
          _RecentReviewCard(theme: theme, review: review),
          if (review != summary.recentReviews.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _RecentReviewCard extends StatelessWidget {
  const _RecentReviewCard({required this.theme, required this.review});

  final ThemeData theme;
  final RecentPlaceReview review;

  @override
  Widget build(BuildContext context) {
    final comments = review.comments.take(2).toList(growable: false);

    return Container(
      key: Key('place-review-item-${review.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author.name ?? 'Avaliador',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${review.overallRating.toStringAsFixed(1)} ★',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryBrand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RecommendationChip(review: review),
              for (final comment in comments)
                _CommentChip(theme: theme, comment: comment),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final localValue = value.toLocal();
    final day = localValue.day.toString().padLeft(2, '0');
    final month = localValue.month.toString().padLeft(2, '0');
    final year = localValue.year.toString();
    return '$day/$month/$year';
  }
}

class _RecommendationChip extends StatelessWidget {
  const _RecommendationChip({required this.review});

  final RecentPlaceReview review;

  @override
  Widget build(BuildContext context) {
    final recommended = review.recommendation.apiValue == 'recommended';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: recommended ? const Color(0xFFEAF6EE) : const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        review.recommendation.summaryLabel,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: recommended
              ? const Color(0xFF2E6B4A)
              : const Color(0xFF8D3F2B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CommentChip extends StatelessWidget {
  const _CommentChip({required this.theme, required this.comment});

  final ThemeData theme;
  final RecentReviewComment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.code.label} ${comment.rating}/5',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment.comment,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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
