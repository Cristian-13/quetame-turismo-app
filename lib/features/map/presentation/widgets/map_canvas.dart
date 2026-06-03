import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/presentation/map_navigation_controller.dart';
import 'package:quetame_turismo/features/map/presentation/map_view_model.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/directional_user_marker.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/premium_site_marker.dart';
import 'package:quetame_turismo/providers/location_provider.dart';

/// Capa de mapa estable con rotación GPS y marcadores unificados.
class MapCanvas extends StatefulWidget {
  final MapController mapController;
  final MapViewModel viewModel;
  final ValueListenable<UserGpsSnapshot?> gpsSnapshot;
  final List<List<LatLng>> geoRoutes;
  final MapNavigationController navigationController;
  final void Function(MapEntity entity) onEntityTap;

  const MapCanvas({
    super.key,
    required this.mapController,
    required this.viewModel,
    required this.gpsSnapshot,
    required this.geoRoutes,
    required this.navigationController,
    required this.onEntityTap,
  });

  @override
  State<MapCanvas> createState() => _MapCanvasState();
}

class _MapCanvasState extends State<MapCanvas> {
  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);
  static const double _defaultMapZoom = 14.0;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant MapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_rebuild);
      widget.viewModel.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png'
        : 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png';
    final filtered = widget.viewModel.filteredEntities;
    final selectedId = widget.viewModel.selectedEntityId;

    final entityMarkers = filtered.map(
      (entity) => Marker(
        width: 48,
        height: 48,
        point: entity.latLng,
        child: PremiumSiteMarker(
          categoryLabel: entity.categoria,
          entityType: entity.type,
          isSelected: selectedId == entity.id,
          onTap: () => widget.onEntityTap(entity),
        ),
      ),
    );

    return RepaintBoundary(
      child: ValueListenableBuilder<UserGpsSnapshot?>(
        valueListenable: widget.gpsSnapshot,
        builder: (context, gps, _) {
          final userMarkers = <Marker>[];
          if (gps != null) {
            userMarkers.add(
              Marker(
                width: 72,
                height: 72,
                point: gps.position,
                child: ValueListenableBuilder<double?>(
                  valueListenable: widget.navigationController.markerHeadingNotifier,
                  builder: (context, markerHeading, _) => DirectionalUserMarker(
                    key: const ValueKey('directional_user_marker'),
                    accuracyMeters: gps.accuracyMeters,
                    headingDegrees: markerHeading ?? gps.headingDegrees,
                  ),
                ),
              ),
            );
          }

          return RepaintBoundary(
            child: FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: _quetameCenter,
                initialZoom: _defaultMapZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture) {
                    widget.navigationController.onUserMapGesture();
                  }
                },
              ),
              children: [
                RepaintBoundary(
                  child: TileLayer(
                    urlTemplate: tileUrl,
                    userAgentPackageName: 'com.quetame_turismo.app',
                  ),
                ),
                if (widget.geoRoutes.isNotEmpty)
                  RepaintBoundary(
                    child: PolylineLayer(
                      polylines: [
                        for (final path in widget.geoRoutes)
                          Polyline(
                            points: path,
                            strokeWidth: 4.0,
                            color: Colors.redAccent,
                          ),
                      ],
                    ),
                  ),
                RepaintBoundary(
                  child: MarkerLayer(markers: entityMarkers.toList()),
                ),
                RepaintBoundary(
                  child: MarkerLayer(markers: userMarkers),
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© CARTO'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
