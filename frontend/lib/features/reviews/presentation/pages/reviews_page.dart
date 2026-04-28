import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../places/domain/models/place_detail.dart';
import '../../../places/domain/places_repository.dart';
import '../../../places/presentation/widgets/place_discovery_section.dart';
import '../../domain/models/review_criterion.dart';
import '../../domain/models/review_criterion_code.dart';
import '../../domain/models/review_recommendation.dart';
import '../../domain/models/review_submission_request.dart';
import '../../domain/models/submitted_review.dart';
import '../../domain/reviews_repository.dart';
import '../controllers/review_create_controller.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({
    super.key,
    required this.reviewsRepository,
    required this.placesRepository,
    this.initialPlace,
  });

  final ReviewsRepository reviewsRepository;
  final PlacesRepository placesRepository;
  final PlaceDetail? initialPlace;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late final ReviewCreateController _controller;
  late PlaceDetail? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _selectedPlace = widget.initialPlace;
    _controller = ReviewCreateController(
      repository: widget.reviewsRepository,
      accessTokenProvider: () =>
          SessionScope.of(context, listen: false).session?.accessToken,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionController = SessionScope.of(context);
    final userName = sessionController.currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(_selectedPlace == null ? 'Escolha o local' : 'Nova avaliacao'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: _selectedPlace == null
                ? PlacesDiscoverySection(
                    repository: widget.placesRepository,
                    accessTokenProvider: () =>
                        sessionController.session?.accessToken,
                    currentUserName: userName,
                    title: 'Escolha o lugar da avaliacao',
                    titleFontSize: 32,
                    onReviewPlaceSelected: _openReviewForPlace,
                  )
                : _ReviewComposer(
                    controller: _controller,
                    place: _selectedPlace!,
                    onBackToChooser: _backToChooser,
                    onReturnToPlace: _returnToPlace,
                  ),
          ),
        ),
      ),
    );
  }

  void _openReviewForPlace(PlaceDetail place) {
    _controller.resetSubmissionState();
    setState(() => _selectedPlace = place);
  }

  void _backToChooser() {
    _controller.resetSubmissionState();
    setState(() => _selectedPlace = null);
  }

  void _returnToPlace(SubmittedReview review) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(review);
      return;
    }

    _controller.resetSubmissionState();
    setState(() => _selectedPlace = null);
  }
}

class _ReviewComposer extends StatefulWidget {
  const _ReviewComposer({
    required this.controller,
    required this.place,
    required this.onBackToChooser,
    required this.onReturnToPlace,
  });

  final ReviewCreateController controller;
  final PlaceDetail place;
  final VoidCallback onBackToChooser;
  final ValueChanged<SubmittedReview> onReturnToPlace;

  @override
  State<_ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends State<_ReviewComposer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Map<ReviewCriterionCode, TextEditingController> _commentControllers;
  late final Map<ReviewCriterionCode, TextEditingController>
  _justificationControllers;
  final Map<ReviewCriterionCode, int?> _ratings = <ReviewCriterionCode, int?>{};
  int? _costBenefitRating;
  ReviewRecommendation? _recommendation;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _commentControllers = {
      for (final code in ReviewCriterionCode.orderedValues)
        code: TextEditingController(),
    };
    _justificationControllers = {
      for (final code in ReviewCriterionCode.orderedValues)
        code: TextEditingController(),
    };
  }

  @override
  void didUpdateWidget(covariant _ReviewComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.id != widget.place.id) {
      _resetForm();
      widget.controller.resetSubmissionState();
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    for (final controller in _justificationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final submittedReview = widget.controller.submittedReview;
        if (submittedReview != null) {
          return _ReviewSuccessCard(
            place: widget.place,
            review: submittedReview,
            onReturnToPlace: () => widget.onReturnToPlace(submittedReview),
            onEvaluateAnother: () {
              widget.controller.resetSubmissionState();
              _resetForm();
              widget.onBackToChooser();
            },
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReviewPlaceHeader(
                place: widget.place,
                onChangePlace: () {
                  widget.controller.resetSubmissionState();
                  _resetForm();
                  widget.onBackToChooser();
                },
              ),
              const SizedBox(height: 20),
              if (widget.controller.errorMessage != null) ...[
                _ReviewInlineFeedback(
                  message: widget.controller.errorMessage!,
                  backgroundColor: const Color(0xFFFFF1EE),
                  borderColor: const Color(0xFFF0C5BB),
                  textColor: const Color(0xFF8D3F2B),
                  icon: Icons.error_outline_rounded,
                ),
                const SizedBox(height: 16),
              ],
              _ReviewProgressCard(completedCount: _completedCriteriaCount),
              const SizedBox(height: 16),
              for (final code in ReviewCriterionCode.orderedValues) ...[
                _CriterionCard(
                  criterion: code,
                  rating: _ratings[code],
                  showErrors: _showValidationErrors,
                  commentController: _commentControllers[code]!,
                  justificationController: _justificationControllers[code]!,
                  onRatingChanged: (value) {
                    widget.controller.clearError();
                    setState(() => _ratings[code] = value);
                  },
                ),
                const SizedBox(height: 16),
              ],
              _SupplementaryReviewCard(
                costBenefitRating: _costBenefitRating,
                recommendation: _recommendation,
                showErrors: _showValidationErrors,
                onCostBenefitChanged: (value) {
                  widget.controller.clearError();
                  setState(() => _costBenefitRating = value);
                },
                onRecommendationChanged: (value) {
                  widget.controller.clearError();
                  setState(() => _recommendation = value);
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const Key('review-submit-button'),
                onPressed: widget.controller.isSubmitting ? null : _submit,
                icon: widget.controller.isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  widget.controller.isSubmitting
                      ? 'Enviando avaliacao...'
                      : 'Enviar avaliacao',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int get _completedCriteriaCount {
    return ReviewCriterionCode.orderedValues
        .where((code) {
          final rating = _ratings[code];
          final comment = _commentControllers[code]!.text.trim();
          final justification = _justificationControllers[code]!.text.trim();
          if (rating == null || comment.isEmpty) {
            return false;
          }
          if (rating < 3 && justification.isEmpty) {
            return false;
          }
          return true;
        })
        .length;
  }

  Future<void> _submit() async {
    widget.controller.clearError();
    setState(() => _showValidationErrors = true);

    final formIsValid = _formKey.currentState?.validate() ?? false;
    final ratingErrors = ReviewCriterionCode.orderedValues.any(
      (code) => _ratings[code] == null,
    );
    final hasCostBenefitError = _costBenefitRating == null;
    final hasRecommendationError = _recommendation == null;
    if (!formIsValid ||
        ratingErrors ||
        hasCostBenefitError ||
        hasRecommendationError) {
      return;
    }

    final request = ReviewSubmissionRequest(
      recommendation: _recommendation!,
      costBenefitRating: _costBenefitRating!,
      criteria: ReviewCriterionCode.orderedValues
          .map(
            (code) => ReviewCriterion(
              code: code,
              rating: _ratings[code]!,
              comment: _commentControllers[code]!.text.trim(),
              justification: _ratings[code]! < 3
                  ? _justificationControllers[code]!.text.trim()
                  : null,
            ),
          )
          .toList(growable: false),
    );

    await widget.controller.submit(placeId: widget.place.id, request: request);
  }

  void _resetForm() {
    setState(() {
      _showValidationErrors = false;
      _costBenefitRating = null;
      _recommendation = null;
      _ratings
        ..clear()
        ..addEntries(
          ReviewCriterionCode.orderedValues.map(
            (code) => MapEntry<ReviewCriterionCode, int?>(code, null),
          ),
        );
      for (final controller in _commentControllers.values) {
        controller.clear();
      }
      for (final controller in _justificationControllers.values) {
        controller.clear();
      }
    });
  }
}

class _ReviewPlaceHeader extends StatelessWidget {
  const _ReviewPlaceHeader({required this.place, required this.onChangePlace});

  final PlaceDetail place;
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
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
                      'Avaliando ${place.name}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${place.street}, ${place.number} — ${place.neighborhood}, ${place.city}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.restaurant_menu_rounded,
                          label: place.category.name,
                        ),
                        _MetaChip(
                          icon: Icons.local_offer_outlined,
                          label: place.subcategory.name,
                        ),
                        _MetaChip(
                          icon: Icons.person_outline_rounded,
                          label: place.createdBy.name ?? 'Autor desconhecido',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                key: const Key('review-change-place-button'),
                onPressed: onChangePlace,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Trocar local'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Seja especifico nos comentarios. Quando uma nota ficar abaixo de 3, explique o contexto para ajudar a leitura futura.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewProgressCard extends StatelessWidget {
  const _ReviewProgressCard({required this.completedCount});

  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final progress = completedCount / ReviewCriterionCode.orderedValues.length;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progresso da avaliacao', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '$completedCount de 4 criterios com nota e texto completos.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppTheme.primaryBrand.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBrand,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriterionCard extends StatelessWidget {
  const _CriterionCard({
    required this.criterion,
    required this.rating,
    required this.showErrors,
    required this.commentController,
    required this.justificationController,
    required this.onRatingChanged,
  });

  final ReviewCriterionCode criterion;
  final int? rating;
  final bool showErrors;
  final TextEditingController commentController;
  final TextEditingController justificationController;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsJustification = (rating ?? 5) < 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(criterion.label, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            criterion.helperText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _RatingField(
            title: 'Nota',
            keyName: 'criterion-rating-${criterion.apiValue}',
            rating: rating,
            errorText: showErrors && rating == null
                ? 'Selecione uma nota entre 1 e 5.'
                : null,
            onChanged: onRatingChanged,
          ),
          const SizedBox(height: 18),
          TextFormField(
            key: Key('criterion-comment-${criterion.apiValue}'),
            controller: commentController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Comentario',
              hintText: 'Descreva o que sustentou essa nota.',
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Comentario obrigatorio.';
              }
              return null;
            },
          ),
          if (needsJustification) ...[
            const SizedBox(height: 18),
            TextFormField(
              key: Key('criterion-justification-${criterion.apiValue}'),
              controller: justificationController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Justificativa da nota baixa',
                hintText:
                    'Explique por que a experiencia ficou abaixo do esperado.',
              ),
              validator: (value) {
                if (!needsJustification) {
                  return null;
                }
                if ((value ?? '').trim().isEmpty) {
                  return 'Justificativa obrigatoria para notas abaixo de 3.';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SupplementaryReviewCard extends StatelessWidget {
  const _SupplementaryReviewCard({
    required this.costBenefitRating,
    required this.recommendation,
    required this.showErrors,
    required this.onCostBenefitChanged,
    required this.onRecommendationChanged,
  });

  final int? costBenefitRating;
  final ReviewRecommendation? recommendation;
  final bool showErrors;
  final ValueChanged<int> onCostBenefitChanged;
  final ValueChanged<ReviewRecommendation> onRecommendationChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fechamento da experiencia', style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Conclua a avaliacao com custo-beneficio e uma recomendacao explicita.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          _RatingField(
            title: 'Custo-beneficio',
            keyName: 'cost-benefit-rating',
            rating: costBenefitRating,
            errorText: showErrors && costBenefitRating == null
                ? 'Informe o custo-beneficio entre 1 e 5.'
                : null,
            onChanged: onCostBenefitChanged,
          ),
          const SizedBox(height: 24),
          Text(
            'Voce recomenda este local?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ReviewRecommendation.values
                .map(
                  (value) => _RecommendationChoice(
                    recommendation: value,
                    selected: recommendation == value,
                    onTap: () => onRecommendationChanged(value),
                  ),
                )
                .toList(growable: false),
          ),
          if (showErrors && recommendation == null) ...[
            const SizedBox(height: 10),
            Text(
              'Escolha uma recomendacao final antes de enviar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8D3F2B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSuccessCard extends StatelessWidget {
  const _ReviewSuccessCard({
    required this.place,
    required this.review,
    required this.onReturnToPlace,
    required this.onEvaluateAnother,
  });

  final PlaceDetail place;
  final SubmittedReview review;
  final VoidCallback onReturnToPlace;
  final VoidCallback onEvaluateAnother;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('review-success-card'),
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          Text('Avaliacao enviada', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Sua review para ${place.name} foi registrada com a recomendacao ${review.recommendation.summaryLabel.toLowerCase()}.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '${place.neighborhood}, ${place.city}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Custo-beneficio: ${review.costBenefitRating}/5',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                key: const Key('review-return-to-place-button'),
                onPressed: onReturnToPlace,
                icon: const Icon(Icons.reply_rounded),
                label: const Text('Voltar ao lugar'),
              ),
              OutlinedButton.icon(
                key: const Key('review-evaluate-another-button'),
                onPressed: onEvaluateAnother,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Avaliar outro local'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({
    required this.title,
    required this.keyName,
    required this.rating,
    required this.onChanged,
    this.errorText,
  });

  final String title;
  final String keyName;
  final int? rating;
  final ValueChanged<int> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(5, (index) {
            final value = index + 1;
            final selected = value <= (rating ?? 0);

            return InkWell(
              key: Key('$keyName-$value'),
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryBrand.withValues(alpha: 0.14)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppTheme.primaryBrand
                        : AppTheme.inputBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 18,
                      color: selected
                          ? AppTheme.primaryBrand
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$value',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AppTheme.primaryBrand
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (rating != null) ...[
          const SizedBox(height: 8),
          Text(
            '$rating de 5',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF8D3F2B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _RecommendationChoice extends StatelessWidget {
  const _RecommendationChoice({
    required this.recommendation,
    required this.selected,
    required this.onTap,
  });

  final ReviewRecommendation recommendation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minWidth: 220),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBrand.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primaryBrand : AppTheme.inputBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppTheme.primaryBrand : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                recommendation.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? AppTheme.primaryBrand
                      : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewInlineFeedback extends StatelessWidget {
  const _ReviewInlineFeedback({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: AppTheme.inputBorder),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ],
);
