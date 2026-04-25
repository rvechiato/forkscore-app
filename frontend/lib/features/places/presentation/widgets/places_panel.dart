import 'package:flutter/material.dart';

import '../../domain/models/place_detail.dart';
import '../controllers/places_controller.dart';

class PlacesPanel extends StatefulWidget {
  const PlacesPanel({
    super.key,
    required this.controller,
    required this.currentUserName,
  });

  final PlacesController controller;
  final String currentUserName;

  @override
  State<PlacesPanel> createState() => _PlacesPanelState();
}

class _PlacesPanelState extends State<PlacesPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E4B2A), Color(0xFFB07443)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Locais do MVP',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cadastre um achado novo, navegue pelo catalogo basico e '
                    'veja quem trouxe cada local para o ForkScore.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFF9EEE4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.controller.errorMessage != null) ...[
              _InlineError(message: widget.controller.errorMessage!),
              const SizedBox(height: 16),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 920;

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildComposer(theme),
                      const SizedBox(height: 16),
                      _buildDetail(theme),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: _buildComposer(theme),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 9,
                      child: _buildDetail(theme),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildComposer(ThemeData theme) {
    final busy = widget.controller.isSaving;

    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cadastrar local',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2E2118),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Autoria atual: ${widget.currentUserName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6A5442),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('place-name-field'),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('place-street-field'),
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'Rua'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('place-number-field'),
                          controller: _numberController,
                          decoration: const InputDecoration(labelText: 'Numero'),
                          validator: _requiredValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('place-neighborhood-field'),
                          controller: _neighborhoodController,
                          decoration: const InputDecoration(labelText: 'Bairro'),
                          validator: _requiredValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('place-city-field'),
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          key: const Key('place-submit-button'),
                          onPressed: busy ? null : _submit,
                          child: Text(
                            busy ? 'Salvando...' : 'Salvar local',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        key: const Key('places-refresh-button'),
                        onPressed: widget.controller.isLoading
                            ? null
                            : widget.controller.loadPlaces,
                        child: const Text('Atualizar lista'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  'Catalogo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2E2118),
                  ),
                ),
                const Spacer(),
                if (widget.controller.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (widget.controller.places.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F1E8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  'Nenhum local cadastrado ainda. O primeiro entra aqui.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6A5442),
                  ),
                ),
              )
            else
              Column(
                children: widget.controller.places
                    .map(
                      (place) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlaceSummaryTile(
                          placeId: place.id,
                          title: place.name,
                          subtitle:
                              '${place.neighborhood}, ${place.city}',
                          authorName: place.createdBy.name,
                          selected:
                              widget.controller.selectedPlace?.id == place.id,
                          onTap: () => widget.controller.selectPlace(place.id),
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

  Widget _buildDetail(ThemeData theme) {
    final place = widget.controller.selectedPlace;

    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: place == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhe do local',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF2E2118),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Selecione um item da lista para abrir o endereco completo '
                    'e a autoria do cadastro.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6A5442),
                    ),
                  ),
                ],
              )
            : _PlaceDetailView(
                place: place,
                loading: widget.controller.isLoadingDetail,
              ),
      ),
    );
  }

  Future<void> _submit() async {
    widget.controller.clearError();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.controller.createPlace(
      name: _nameController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
    );

    if (widget.controller.errorMessage != null) {
      return;
    }

    _nameController.clear();
    _streetController.clear();
    _numberController.clear();
    _neighborhoodController.clear();
    _cityController.clear();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio.';
    }
    return null;
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.97),
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: const Color(0xFFE4DDD0)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 22,
        offset: Offset(0, 14),
      ),
    ],
  );
}

class _PlaceSummaryTile extends StatelessWidget {
  const _PlaceSummaryTile({
    required this.placeId,
    required this.title,
    required this.subtitle,
    required this.authorName,
    required this.selected,
    required this.onTap,
  });

  final String placeId;
  final String title;
  final String subtitle;
  final String? authorName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('place-list-item-$placeId'),
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1E0CC) : const Color(0xFFF9F5EF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFB07443) : const Color(0xFFE4DDD0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2E2118),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6A5442),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                authorName == null ? 'Autor desconhecido' : 'Por $authorName',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B4B2D),
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

class _PlaceDetailView extends StatelessWidget {
  const _PlaceDetailView({
    required this.place,
    required this.loading,
  });

  final PlaceDetail place;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                place.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF2E2118),
                ),
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
        _DetailLine(label: 'Rua', value: place.street),
        _DetailLine(label: 'Numero', value: place.number),
        _DetailLine(label: 'Bairro', value: place.neighborhood),
        _DetailLine(label: 'Cidade', value: place.city),
        _DetailLine(
          label: 'Autoria',
          value: place.createdBy.name ?? 'Autor desconhecido',
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF4E5D3), Color(0xFFF9F4ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Endereco completo: ${place.street}, ${place.number} - '
            '${place.neighborhood}, ${place.city}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5C4331),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF5C4331),
        ),
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
        color: const Color(0xFFFBE8E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF8A2E1D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
