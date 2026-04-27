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
                    const SizedBox(height: 20),
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
                    borderRadius: BorderRadius.circular(4),
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

    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Lugares cadastrados', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (controller.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Selecione um resultado para conferir os detalhes.'
                  : 'Resultados filtrados para a busca atual.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (places.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  query.isEmpty
                      ? 'Nenhum lugar cadastrado ainda.'
                      : 'Nenhum lugar corresponde a essa busca.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              Column(
                children: places
                    .map(
                      (place) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlaceSummaryTile(
                          place: place,
                          selected: controller.selectedPlace?.id == place.id,
                          onTap: () => controller.selectPlace(place.id),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

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

    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: place == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalhe do lugar', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Abra um item da lista para ver endereco completo e '
                    'confirmar a autoria antes de avaliar.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrand.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Avaliador atual: $currentUserName',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBrand,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _DetailLine(label: 'Rua', value: place!.street),
                  _DetailLine(label: 'Numero', value: place!.number),
                  _DetailLine(label: 'Bairro', value: place!.neighborhood),
                  _DetailLine(label: 'Cidade', value: place!.city),
                  _DetailLine(label: 'Categoria', value: place!.category.name),
                  _DetailLine(
                    label: 'Subcategoria',
                    value: place!.subcategory.name,
                  ),
                  _DetailLine(
                    label: 'Autoria',
                    value: place!.createdBy.name ?? 'Autor desconhecido',
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Endereco completo: ${place!.street}, ${place!.number} - '
                      '${place!.neighborhood}, ${place!.city}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PlaceSummaryTile extends StatelessWidget {
  const _PlaceSummaryTile({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final PlaceSummary place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      key: Key('place-search-result-${place.id}'),
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.inputBorder)),
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
            const SizedBox(height: 6),
            Text(
              '${place.category.name} • ${place.subcategory.name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(),
              child: Text(
                place.createdBy.name == null
                    ? 'Autor desconhecido'
                    : 'Por ${place.createdBy.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryBrand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0C5BB)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8D3F2B)),
      ),
    );
  }
}

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppTheme.inputBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x06000000), blurRadius: 20, offset: Offset(0, 8)),
  ],
);
