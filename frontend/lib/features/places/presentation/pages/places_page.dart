import 'package:flutter/material.dart';

import '../../../../app/auth_scope.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/models/place_detail.dart';
import '../../domain/models/place_summary.dart';
import '../../domain/places_repository.dart';
import '../controllers/places_controller.dart';
import 'place_create_page.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key, required this.repository});

  final PlacesRepository repository;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  late final TextEditingController _searchController;
  PlacesController? _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) {
      return;
    }

    final sessionController = SessionScope.of(context, listen: false);
    _controller = PlacesController(
      repository: widget.repository,
      accessTokenProvider: () => sessionController.session?.accessToken,
    )..loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final userName = SessionScope.of(context).currentUser?.name ?? 'Gastronomo';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Pesquisa de Lugares'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final visiblePlaces = _filterPlaces(controller.places, _query);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlacesHero(
                      query: _query,
                      searchController: _searchController,
                      onChanged: (value) {
                        setState(() => _query = value.trim().toLowerCase());
                      },
                      onCreatePressed: () => _openCreatePage(controller),
                    ),
                    const SizedBox(height: 24),
                    if (controller.errorMessage != null) ...[
                      _InlineError(message: controller.errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 940;
                        final results = _PlacesResultsCard(
                          controller: controller,
                          places: visiblePlaces,
                          query: _query,
                        );
                        final detail = _PlacesDetailCard(
                          place: controller.selectedPlace,
                          loading: controller.isLoadingDetail,
                          currentUserName: userName,
                        );

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              results,
                              const SizedBox(height: 16),
                              detail,
                            ],
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
              ),
            ),
          );
        },
      ),
    );
  }

  List<PlaceSummary> _filterPlaces(List<PlaceSummary> places, String query) {
    if (query.isEmpty) {
      return places;
    }

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
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  Future<void> _openCreatePage(PlacesController controller) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => PlaceCreatePage(controller: controller),
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    controller.clearError();
    await controller.loadPlaces();
  }
}

// ---------------------------------------------------------------------------
// Hero / Header
// ---------------------------------------------------------------------------

class _PlacesHero extends StatelessWidget {
  const _PlacesHero({
    required this.query,
    required this.searchController,
    required this.onChanged,
    required this.onCreatePressed,
  });

  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.inputBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              'Fluxo de avaliacao',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryBrand,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Escolha o lugar da avaliacao',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 42,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pesquise entre os lugares cadastrados ou abra um novo '
            'estabelecimento antes de registrar sua experiencia.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
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

// ---------------------------------------------------------------------------
// Results list card
// ---------------------------------------------------------------------------

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row ──────────────────────────────────────────
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

            // ── List ────────────────────────────────────────────────
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
                  final isSelected =
                      controller.selectedPlace?.id == place.id;

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

// ---------------------------------------------------------------------------
// Single place tile
// ---------------------------------------------------------------------------

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
              // ── Category icon ───────────────────────────────────
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

              // ── Text content ────────────────────────────────────
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

              // ── Tags ────────────────────────────────────────────
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

              // ── Chevron ─────────────────────────────────────────
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

// ---------------------------------------------------------------------------
// Tag chip
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Detail card
// ---------------------------------------------------------------------------

class _PlacesDetailCard extends StatelessWidget {
  const _PlacesDetailCard({
    required this.place,
    required this.loading,
    required this.currentUserName,
  });

  final PlaceDetail? place;
  final bool loading;
  final String currentUserName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
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
        // ── Header ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                place!.name,
                style: theme.textTheme.headlineSmall,
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
        const SizedBox(height: 6),
        Row(
          children: [
            _TagChip(
              label: place!.category.name,
              color: AppTheme.primaryBrand,
            ),
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

        // ── Details grid ────────────────────────────────────────
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

        // ── Full address summary ────────────────────────────────
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
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail row (label + value with icon)
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Inline error
// ---------------------------------------------------------------------------

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8D3F2B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
