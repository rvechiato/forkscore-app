import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/place_location_map.dart';
import '../../domain/models/place_location_suggestion.dart';
import '../../domain/place_location_search_repository.dart';

class PlaceLocationPicker extends StatefulWidget {
  const PlaceLocationPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.searchRepository,
    required this.onLocationChanged,
    required this.onClear,
  });

  final double? latitude;
  final double? longitude;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final PlaceLocationSearchRepository searchRepository;
  final PlaceLocationSelected onLocationChanged;
  final VoidCallback onClear;

  @override
  State<PlaceLocationPicker> createState() => _PlaceLocationPickerState();
}

class _PlaceLocationPickerState extends State<PlaceLocationPicker> {
  var _isSearching = false;
  String? _searchMessage;
  List<PlaceLocationSuggestion> _suggestions = const [];

  bool get _hasLocation => latitude != null && longitude != null;
  bool get _canSearch => _addressParts.length >= 2;

  double? get latitude => widget.latitude;
  double? get longitude => widget.longitude;

  @override
  void didUpdateWidget(covariant PlaceLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.street != widget.street ||
        oldWidget.number != widget.number ||
        oldWidget.neighborhood != widget.neighborhood ||
        oldWidget.city != widget.city) {
      _searchMessage = null;
      _suggestions = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('place-location-picker'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppTheme.primaryBrand,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Localizacao no mapa',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasLocation
                          ? 'Localizacao definida. Toque em outro ponto para ajustar.'
                          : 'Localize pelo endereco ou toque no mapa para marcar.',
                      key: Key(
                        _hasLocation
                            ? 'place-location-picker-selected'
                            : 'place-location-picker-empty',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasLocation)
                TextButton.icon(
                  key: const Key('place-location-clear-button'),
                  onPressed: _clearLocation,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Limpar'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('place-location-search-button'),
            onPressed: _canSearch && !_isSearching ? _searchByAddress : null,
            icon: _isSearching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(
              _isSearching ? 'Localizando...' : 'Localizar pelo endereco',
            ),
          ),
          if (!_canSearch) ...[
            const SizedBox(height: 8),
            Text(
              'Preencha pelo menos rua e cidade para buscar no mapa.',
              key: const Key('place-location-search-disabled-message'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          if (_searchMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              key: const Key('place-location-search-message'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_suggestions.length > 1) ...[
            const SizedBox(height: 10),
            ..._suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  key: Key('place-location-suggestion-${suggestion.label}'),
                  onPressed: () => _selectSuggestion(suggestion),
                  icon: const Icon(Icons.place_outlined, size: 18),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      suggestion.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          PlaceLocationMap(
            latitude: latitude,
            longitude: longitude,
            interactive: true,
            onLocationSelected: _setManualLocation,
            semanticLabel: _hasLocation
                ? 'Localizacao do estabelecimento definida.'
                : 'Mapa interativo para marcar a localizacao do estabelecimento.',
          ),
          if (_hasLocation) ...[
            const SizedBox(height: 10),
            Text(
              'Coordenadas: ${latitude!.toStringAsFixed(5)}, '
              '${longitude!.toStringAsFixed(5)}',
              key: const Key('place-location-picker-coordinates'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _searchByAddress() async {
    setState(() {
      _isSearching = true;
      _searchMessage = null;
      _suggestions = const [];
    });

    try {
      final suggestions = await widget.searchRepository.searchByAddress(
        street: widget.street,
        number: widget.number,
        neighborhood: widget.neighborhood,
        city: widget.city,
      );
      if (!mounted) {
        return;
      }

      if (suggestions.isEmpty) {
        setState(() {
          _searchMessage =
              'Nao encontramos esse endereco. Voce ainda pode marcar no mapa.';
        });
        return;
      }

      final firstSuggestion = suggestions.first;
      widget.onLocationChanged(
        firstSuggestion.latitude,
        firstSuggestion.longitude,
      );
      setState(() {
        _suggestions = suggestions;
        _searchMessage = suggestions.length == 1
            ? 'Marcador sugerido pelo endereco. Confira e ajuste se precisar.'
            : 'Escolha uma sugestao ou ajuste o marcador no mapa.';
      });
    } on PlaceLocationSearchException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _searchMessage = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchMessage =
            'Nao foi possivel localizar o endereco. Voce ainda pode marcar no mapa.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectSuggestion(PlaceLocationSuggestion suggestion) {
    widget.onLocationChanged(suggestion.latitude, suggestion.longitude);
    setState(() {
      _searchMessage = 'Sugestao selecionada. Confira e ajuste se precisar.';
    });
  }

  void _setManualLocation(double latitude, double longitude) {
    widget.onLocationChanged(latitude, longitude);
    setState(() {
      _searchMessage = null;
      _suggestions = const [];
    });
  }

  void _clearLocation() {
    widget.onClear();
    setState(() {
      _searchMessage = null;
      _suggestions = const [];
    });
  }

  List<String> get _addressParts {
    return [widget.street, widget.number, widget.neighborhood, widget.city]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}
