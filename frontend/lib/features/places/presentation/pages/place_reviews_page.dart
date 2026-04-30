import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../app/navigation/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/authenticated_page_scaffold.dart';
import '../../../reviews/domain/models/recent_place_review.dart';
import '../../../reviews/domain/models/recent_review_comment.dart';
import '../../../reviews/domain/reviews_repository.dart';
import '../../../reviews/presentation/widgets/place_review_summary_section.dart';
import '../../data/forkscore_api_places_repository.dart';
import '../../domain/models/place_detail.dart';
import '../../domain/places_repository.dart';

class PlaceReviewsPage extends StatefulWidget {
  const PlaceReviewsPage({
    super.key,
    required this.placesRepository,
    required this.reviewsRepository,
    required this.placeId,
    this.initialPlace,
  });

  final PlacesRepository placesRepository;
  final ReviewsRepository reviewsRepository;
  final String placeId;
  final PlaceDetail? initialPlace;

  @override
  State<PlaceReviewsPage> createState() => _PlaceReviewsPageState();
}

class _PlaceReviewsPageState extends State<PlaceReviewsPage> {
  PlaceDetail? _place;
  bool _isLoadingPlace = false;
  String? _placeError;

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace;
    if (_place == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlace());
    }
  }

  @override
  void didUpdateWidget(covariant PlaceReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _place = widget.initialPlace;
      _placeError = null;
      if (_place == null) {
        _loadPlace();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final accessToken = sessionController.session?.accessToken;

    return AuthenticatedPageScaffold(
      maxWidth: 1040,
      showBackButton: true,
      child: _buildBody(context, accessToken),
    );
  }

  Widget _buildBody(BuildContext context, String? accessToken) {
    if (_isLoadingPlace && _place == null) {
      return const _PageStatus(
        icon: Icons.storefront_rounded,
        title: 'Carregando o lugar',
        message: 'Buscando os dados do estabelecimento selecionado.',
        showLoader: true,
      );
    }

    if (_placeError case final message? when _place == null) {
      return _PageStatus(
        icon: Icons.error_outline_rounded,
        title: 'Nao foi possivel abrir o lugar',
        message: message,
        action: OutlinedButton.icon(
          onPressed: _loadPlace,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      );
    }

    final place = _place;
    if (place == null) {
      return _PageStatus(
        icon: Icons.error_outline_rounded,
        title: 'Lugar nao informado',
        message: 'Volte para a home e escolha um lugar da lista.',
        action: FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Voltar para home'),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final header = _PlaceHeaderCard(place: place, loading: _isLoadingPlace);
        final summary = PlaceReviewSummarySection(
          key: ValueKey('place-reviews-summary-${place.id}'),
          placeId: place.id,
          repository: widget.reviewsRepository,
          accessTokenProvider: () => accessToken,
        );
        final reviews = _PlaceReviewsListSection(
          key: ValueKey('place-reviews-list-${place.id}'),
          placeId: place.id,
          repository: widget.reviewsRepository,
          accessTokenProvider: () => accessToken,
        );
        final cta = _ReviewCtaCard(
          place: place,
          onReviewPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.reviews,
              arguments: ReviewsRouteArgs(initialPlace: place),
            );
          },
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 16),
              summary,
              const SizedBox(height: 16),
              reviews,
              const SizedBox(height: 16),
              cta,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [header, const SizedBox(height: 16), reviews],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [summary, const SizedBox(height: 16), cta],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadPlace() async {
    final accessToken = SessionScope.of(context).session?.accessToken;
    if (accessToken == null || widget.placeId.isEmpty) {
      setState(() {
        _placeError = 'Sua sessao expirou. Entre novamente para ver o lugar.';
      });
      return;
    }

    setState(() {
      _isLoadingPlace = true;
      _placeError = null;
    });

    try {
      final place = await widget.placesRepository.getPlaceById(
        accessToken: accessToken,
        placeId: widget.placeId,
      );
      if (!mounted) {
        return;
      }
      setState(() => _place = place);
    } on PlacesRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _placeError = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _placeError = 'Nao foi possivel carregar o detalhe do lugar.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlace = false);
      }
    }
  }
}

class _PlaceHeaderCard extends StatelessWidget {
  const _PlaceHeaderCard({required this.place, required this.loading});

  final PlaceDetail place;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('place-reviews-header'),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(
                label: place.category.name,
                color: AppTheme.primaryBrand,
              ),
              _TagChip(
                label: place.subcategory.name,
                color: AppTheme.accentGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailLine(
            icon: Icons.place_outlined,
            label: 'Endereco',
            value: '${place.street}, ${place.number}',
          ),
          _DetailLine(
            icon: Icons.map_outlined,
            label: 'Bairro',
            value: place.neighborhood,
          ),
          _DetailLine(
            icon: Icons.location_city_rounded,
            label: 'Cidade',
            value: place.city,
          ),
          _DetailLine(
            icon: Icons.person_outline_rounded,
            label: 'Autoria',
            value: place.createdBy.name ?? 'Autor desconhecido',
          ),
        ],
      ),
    );
  }
}

class _PlaceReviewsListSection extends StatefulWidget {
  const _PlaceReviewsListSection({
    super.key,
    required this.placeId,
    required this.repository,
    required this.accessTokenProvider,
  });

  final String placeId;
  final ReviewsRepository repository;
  final String? Function() accessTokenProvider;

  @override
  State<_PlaceReviewsListSection> createState() =>
      _PlaceReviewsListSectionState();
}

class _PlaceReviewsListSectionState extends State<_PlaceReviewsListSection> {
  late Future<List<RecentPlaceReview>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _PlaceReviewsListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _future = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('place-reviews-list-section'),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: FutureBuilder<List<RecentPlaceReview>>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final reviews = snapshot.data ?? const <RecentPlaceReview>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 20,
                    color: AppTheme.primaryBrand,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reviews',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (snapshot.hasError)
                _ReviewsError(
                  message: _errorMessage(snapshot.error),
                  onRetry: () => setState(() => _future = _load()),
                )
              else if (loading)
                Text(
                  'Carregando as reviews deste lugar...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                )
              else if (reviews.isEmpty)
                Text(
                  'Ainda nao existem reviews para este local.',
                  key: const Key('place-reviews-list-empty'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                for (final review in reviews) ...[
                  _FullReviewCard(review: review),
                  if (review != reviews.last) const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<List<RecentPlaceReview>> _load() async {
    final accessToken = widget.accessTokenProvider();
    if (accessToken == null) {
      throw ReviewsRepositoryException(
        'Sua sessao expirou. Entre novamente para ver reviews.',
      );
    }

    return widget.repository.listPlaceReviews(
      accessToken: accessToken,
      placeId: widget.placeId,
    );
  }

  String _errorMessage(Object? error) {
    if (error is ReviewsRepositoryException) {
      return error.message;
    }
    return 'Nao foi possivel carregar as reviews.';
  }
}

class _FullReviewCard extends StatelessWidget {
  const _FullReviewCard({required this.review});

  final RecentPlaceReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: Key('place-review-full-item-${review.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
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
                      style: theme.textTheme.titleMedium?.copyWith(
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
              _RatingBadge(rating: review.overallRating),
            ],
          ),
          const SizedBox(height: 12),
          _RecommendationPill(review: review),
          const SizedBox(height: 12),
          for (final comment in review.comments) ...[
            _ReviewCommentLine(comment: comment),
            if (comment != review.comments.last) const SizedBox(height: 10),
          ],
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

class _ReviewCtaCard extends StatelessWidget {
  const _ReviewCtaCard({required this.place, required this.onReviewPressed});

  final PlaceDetail place;
  final VoidCallback onReviewPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrand.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBrand.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avaliou ${place.name}?',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre sua experiencia pelos criterios do ForkScore.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('start-review-button'),
              onPressed: onReviewPressed,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Avaliar este local'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCommentLine extends StatelessWidget {
  const _ReviewCommentLine({required this.comment});

  final RecentReviewComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationPill extends StatelessWidget {
  const _RecommendationPill({required this.review});

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

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${rating.toStringAsFixed(1)} estrela${rating == 1 ? '' : 's'}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.primaryBrand,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReviewsError extends StatelessWidget {
  const _ReviewsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: const Key('place-reviews-list-error'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF8D3F2B),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      ],
    );
  }
}

class _PageStatus extends StatelessWidget {
  const _PageStatus({
    required this.icon,
    required this.title,
    required this.message,
    this.showLoader = false,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showLoader;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: AppTheme.primaryBrand),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (showLoader) ...[
            const SizedBox(height: 18),
            const CircularProgressIndicator(strokeWidth: 2.2),
          ],
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: AppTheme.inputBorder),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ],
);
