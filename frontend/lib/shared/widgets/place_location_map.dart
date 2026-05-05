import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

typedef PlaceLocationSelected =
    void Function(double latitude, double longitude);

class PlaceLocationMap extends StatelessWidget {
  const PlaceLocationMap({
    super.key,
    this.latitude,
    this.longitude,
    this.interactive = false,
    this.onLocationSelected,
    this.height = 220,
    this.semanticLabel,
  });

  static const defaultCenter = LatLng(-25.4284, -49.2733);

  final double? latitude;
  final double? longitude;
  final bool interactive;
  final PlaceLocationSelected? onLocationSelected;
  final double height;
  final String? semanticLabel;

  bool get _hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    final markerPoint = _hasLocation ? LatLng(latitude!, longitude!) : null;
    final center = markerPoint ?? defaultCenter;

    return Semantics(
      label: semanticLabel ?? _semanticLabel,
      button: interactive,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          key: const Key('place-location-map'),
          height: height,
          width: double.infinity,
          child: FlutterMap(
            key: ValueKey(
              markerPoint == null
                  ? 'place-location-map-empty'
                  : 'place-location-map-${latitude!.toStringAsFixed(5)}-${longitude!.toStringAsFixed(5)}',
            ),
            options: MapOptions(
              initialCenter: center,
              initialZoom: markerPoint == null ? 12 : 15,
              interactionOptions: InteractionOptions(
                flags: interactive
                    ? InteractiveFlag.all
                    : InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              onTap: interactive && onLocationSelected != null
                  ? (_, point) =>
                        onLocationSelected!(point.latitude, point.longitude)
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.forkscore.app',
              ),
              if (markerPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      key: const Key('place-location-marker'),
                      point: markerPoint,
                      width: 46,
                      height: 46,
                      child: const _PlaceMarker(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _semanticLabel {
    if (_hasLocation) {
      return 'Localizacao marcada em ${latitude!.toStringAsFixed(5)}, '
          '${longitude!.toStringAsFixed(5)}.';
    }
    return interactive
        ? 'Mapa para marcar a localizacao do estabelecimento.'
        : 'Mapa sem localizacao marcada.';
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.primaryBrand,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.place_rounded, color: Colors.white, size: 28),
    );
  }
}
