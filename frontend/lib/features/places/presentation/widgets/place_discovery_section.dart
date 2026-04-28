import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/models/place_detail.dart';
import '../../domain/models/place_summary.dart';
import '../../domain/places_repository.dart';
import '../controllers/places_controller.dart';
import '../pages/place_create_page.dart';

class PlacesDiscoverySection extends StatefulWidget {
  const PlacesDiscoverySection({
    super.key,
    this.controller,
    this.repository,
    this.accessTokenProvider,
    this.onReviewPlaceSelected,
    required this.currentUserName,
    this.eyebrow = 'Fluxo de avaliacao',
    this.title = 'Escolha o lugar da avaliacao',
    this.description =
        'Pesquise entre os lugares cadastrados ou abra um novo '
        'estabelecimento antes de registrar sua experiencia.',
    this.titleFontSize = 42,
    this.contentPadding = EdgeInsets.zero,
    this.showHeroDivider = true,
  }) : assert(
         controller != null ||
             (repository != null && accessTokenProvider != null),
         'Provide a controller or both repository and accessTokenProvider.',
       );

  final PlacesController? controller;
  final PlacesRepository? repository;
  final String? Function()? accessTokenProvider;
  final ValueChanged<PlaceDetail>? onReviewPlaceSelected;
  final String currentUserName;
  final String eyebrow;
  final String title;
  final String description;
  final double titleFontSize;
  final EdgeInsetsGeometry contentPadding;
  final bool showHeroDivider;

  @override
  State<PlacesDiscoverySection> createState() => _PlacesDiscoverySectionState();
}

class _PlacesDiscoverySectionState extends State<PlacesDiscoverySection> {
  late final TextEditingController _searchController;
  late PlacesController _controller;
  late bool _ownsController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _configureController();
  }

  @override
  void didUpdateWidget(covariant PlacesDiscoverySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller &&
        oldWidget.repository == widget.repository) {
      return;
    }

    if (_ownsController) {
      _controller.dispose();
    }
    _configureController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final visiblePlaces = _filterPlaces(_controller.places, _query);

        return Padding(
          padding: widget.contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlacesHero(
                eyebrow: widget.eyebrow,
                title: widget.title,
                description: widget.description,
                titleFontSize: widget.titleFontSize,
                query: _query,
                showDivider: widget.showHeroDivider,
                searchController: _searchController,
                onChanged: (value) {
                  setState(() => _query = value.trim());
                },
                onCreatePressed: _openCreatePage,
              ),
              const SizedBox(height: 24),
              if (_controller.errorMessage != null) ...[
                PlacesInlineError(message: _controller.errorMessage!),
                const SizedBox(height: 16),
              ],
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 940;
                  final results = _PlacesResultsCard(
                    controller: _controller,
                    places: visiblePlaces,
                    query: _query,
                  );
                  final detail = _PlacesDetailCard(
                    place: _controller.selectedPlace,
                    loading: _controller.isLoadingDetail,
                    currentUserName: widget.currentUserName,
                    onReviewPlaceSelected: widget.onReviewPlaceSelected,
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [results, const SizedBox(height: 16), detail],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 11, child: results),
                      const SizedBox(width: 16),
                      Expanded(flex: 9, child: detail),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _configureController() {
    final externalController = widget.controller;
    if (externalController != null) {
      _controller = externalController;
      _ownsController = false;
    } else {
      final repository = widget.repository;
      final accessTokenProvider = widget.accessTokenProvider;
      assert(
        repository != null,
        'repository is required when controller is not provided',
      );
      assert(
        accessTokenProvider != null,
        'accessTokenProvider is required when controller is not provided',
      );
      _controller = PlacesController(
        repository: repository!,
        accessTokenProvider: accessTokenProvider!,
      );
      _ownsController = true;
    }

    if (_controller.places.isEmpty && !_controller.isLoading) {
      _controller.loadPlaces();
    }
  }

  List<PlaceSummary> _filterPlaces(List<PlaceSummary> places, String query) {
    if (query.isEmpty) {
      return places;
    }

    final normalizedQuery = query.toLowerCase();
    return places
        .where((place) {
          final authorName = place.createdBy.name ?? '';
          final haystack = <String>[
            place.name,
            place.neighborhood,
            place.city,
            place.category.name,
            place.subcategory.name,
            authorName,
          ].join(' ').toLowerCase();
          return haystack.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => PlaceCreatePage(controller: _controller),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    _controller.clearError();
    await _controller.loadPlaces();
  }
}

class _PlacesHero extends StatelessWidget {
  const _PlacesHero({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.titleFontSize,
    required this.query,
    required this.showDivider,
    required this.searchController,
    required this.onChanged,
    required this.onCreatePressed,
  });

  final String eyebrow;
  final String title;
  final String description;
  final double titleFontSize;
  final String query;
  final bool showDivider;
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEyebrow = eyebrow.trim().isNotEmpty;
    final hasDescription = description.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppTheme.inputBorder))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEyebrow) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrand.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppTheme.primaryBrand.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                eyebrow,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryBrand,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: titleFontSize,
              color: AppTheme.textPrimary,
            ),
          ),
          if (hasDescription) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;

              final searchField = TextField(
                key: const Key('places-search-field'),
                controller: searchController,
                onChanged: onChanged,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Busque por nome, bairro, cidade ou autoria',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppTheme.primaryBrand.withValues(alpha: 0.03),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            onChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              );

              final createButton = FilledButton.icon(
                key: const Key('new-establishment-button'),
                onPressed: onCreatePressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Novo Estabelecimento'),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    createButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 7, child: searchField),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: createButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlacesResultsCard extends StatelessWidget {
  const _PlacesResultsCard({
    required this.controller,
    required this.places,
    required this.query,
  });

  final PlacesController controller;
  final List<PlaceSummary> places;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lugares cadastrados',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        query.isEmpty
                            ? '${places.length} resultado${places.length != 1 ? 's' : ''}'
                            : '${places.length} resultado${places.length != 1 ? 's' : ''} para "$query"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                else
                  IconButton(
                    onPressed: controller.loadPlaces,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    tooltip: 'Atualizar lista',
                    style: IconButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (places.isEmpty)
              _EmptyState(hasQuery: query.isNotEmpty)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: places.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final place = places[index];
                  final isSelected = controller.selectedPlace?.id == place.id;

                  return _PlaceSummaryTile(
                    place: place,
                    selected: isSelected,
                    onTap: () => controller.selectPlace(place.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceSummaryTile extends StatefulWidget {
  const _PlaceSummaryTile({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final PlaceSummary place;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PlaceSummaryTile> createState() => _PlaceSummaryTileState();
}

class _PlaceSummaryTileState extends State<_PlaceSummaryTile> {
  bool _hovered = false;

  IconData _categoryIcon(String slug) {
    switch (slug) {
      case 'restaurantes':
        return Icons.restaurant_rounded;
      case 'cafeterias':
        return Icons.coffee_rounded;
      case 'bares':
        return Icons.local_bar_rounded;
      case 'padarias':
        return Icons.bakery_dining_rounded;
      case 'docerias':
        return Icons.cake_rounded;
      case 'pizzarias':
        return Icons.local_pizza_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = widget.place;
    final selected = widget.selected;

    final bgColor = selected
        ? AppTheme.primaryBrand.withValues(alpha: 0.07)
        : _hovered
        ? AppTheme.primaryBrand.withValues(alpha: 0.03)
        : Colors.transparent;

    final borderColor = selected
        ? AppTheme.primaryBrand.withValues(alpha: 0.25)
        : _hovered
        ? AppTheme.inputBorder
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          key: Key('place-search-result-${place.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryBrand.withValues(alpha: 0.12)
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(place.category.slug),
                  size: 22,
                  color: selected
                      ? AppTheme.primaryBrand
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${place.neighborhood}, ${place.city}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TagChip(
                    label: place.category.name,
                    color: AppTheme.primaryBrand,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.createdBy.name ?? 'Autor desconhecido',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: selected
                    ? AppTheme.primaryBrand
                    : AppTheme.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryBrand.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hasQuery ? Icons.search_off_rounded : Icons.store_outlined,
              size: 28,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'Nenhum resultado encontrado'
                : 'Nenhum lugar cadastrado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery
                ? 'Tente ajustar os termos da busca ou cadastre um novo lugar.'
                : 'Comece cadastrando o primeiro estabelecimento.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlacesDetailCard extends StatelessWidget {
  const _PlacesDetailCard({
    required this.place,
    required this.loading,
    required this.currentUserName,
    required this.onReviewPlaceSelected,
  });

  final PlaceDetail? place;
  final bool loading;
  final String currentUserName;
  final ValueChanged<PlaceDetail>? onReviewPlaceSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: place == null
            ? _buildEmptyDetail(theme)
            : _buildPlaceDetail(theme),
      ),
    );
  }

  Widget _buildEmptyDetail(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrand.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Text('Detalhe do lugar', style: theme.textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Selecione um item da lista para ver o endereco completo e '
          'confirmar a autoria antes de avaliar.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBrand.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBrand.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppTheme.primaryBrand,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Avaliador atual: $currentUserName',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceDetail(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(place!.name, style: theme.textTheme.headlineSmall),
            ),
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _TagChip(label: place!.category.name, color: AppTheme.primaryBrand),
            const SizedBox(width: 8),
            _TagChip(
              label: place!.subcategory.name,
              color: AppTheme.accentGreen,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 20),
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Rua',
          value: place!.street,
        ),
        _DetailRow(
          icon: Icons.tag_rounded,
          label: 'Numero',
          value: place!.number,
        ),
        _DetailRow(
          icon: Icons.map_outlined,
          label: 'Bairro',
          value: place!.neighborhood,
        ),
        _DetailRow(
          icon: Icons.location_city_rounded,
          label: 'Cidade',
          value: place!.city,
        ),
        _DetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Autoria',
          value: place!.createdBy.name ?? 'Autor desconhecido',
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.place_rounded,
                size: 18,
                color: AppTheme.primaryBrand,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${place!.street}, ${place!.number} — '
                  '${place!.neighborhood}, ${place!.city}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (onReviewPlaceSelected != null) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('start-review-button'),
            onPressed: () => onReviewPlaceSelected!(place!),
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Avaliar este local'),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
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

class PlacesInlineError extends StatelessWidget {
  const PlacesInlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C5BB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFF8D3F2B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8D3F2B)),
            ),
          ),
        ],
      ),
    );
  }
}

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppTheme.inputBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 8)),
  ],
);
