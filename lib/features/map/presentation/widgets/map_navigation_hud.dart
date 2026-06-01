import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';

/// HUD de telemetría para rutas ecológicas.
class MapNavigationHud extends StatelessWidget {
  const MapNavigationHud({super.key});

  static const LatLng _quetameStart = LatLng(4.3303, -73.8647);
  static const double _warningDistanceMeters = 50;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeProvider = context.watch<RouteProvider>();
    final locationProvider = context.read<LocationProvider>();

    return ValueListenableBuilder<UserGpsSnapshot?>(
      valueListenable: locationProvider.gpsSnapshotNotifier,
      builder: (context, gps, _) {
        final current = gps?.position ?? locationProvider.currentLocation;
        final speedKmh = gps?.speedKmh ?? 0;
        final route = routeProvider.activePlaceRoute;
        final remainingMeters = _remainingDistanceMeters(
          currentPosition: current,
          routePoints: route,
        );
        final warning = _shouldWarn(
          currentPosition: current,
          routePoints: route,
        );

        final speedLabel =
            speedKmh > 0 ? '${speedKmh.toStringAsFixed(0)} km/h' : '0 km/h';
        final distanceLabel = _formatDistance(remainingMeters);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: warning
                      ? Colors.red.withValues(alpha: 0.45)
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HudMetric(
                    icon: Icons.speed_rounded,
                    label: 'Velocidad',
                    value: speedLabel,
                    theme: theme,
                    large: false,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  _HudMetric(
                    icon: Icons.route_rounded,
                    label: 'Restante',
                    value: distanceLabel,
                    theme: theme,
                    large: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double? _remainingDistanceMeters({
    required LatLng? currentPosition,
    required List<LatLng> routePoints,
  }) {
    if (currentPosition == null || routePoints.isEmpty) return null;
    if (routePoints.length == 1) {
      return const Distance().as(
        LengthUnit.Meter,
        currentPosition,
        routePoints.first,
      );
    }

    final nearestIndex = _nearestVertexIndex(currentPosition, routePoints);
    final distance = const Distance();
    var total = distance.as(
      LengthUnit.Meter,
      currentPosition,
      routePoints[nearestIndex],
    );
    for (var i = nearestIndex; i < routePoints.length - 1; i++) {
      total += distance.as(
        LengthUnit.Meter,
        routePoints[i],
        routePoints[i + 1],
      );
    }
    return total;
  }

  bool _shouldWarn({
    required LatLng? currentPosition,
    required List<LatLng> routePoints,
  }) {
    if (currentPosition == null) return false;
    final distance = const Distance();
    final fromStart = distance.as(
      LengthUnit.Meter,
      currentPosition,
      _quetameStart,
    );
    if (fromStart > _warningDistanceMeters) return true;
    if (routePoints.isEmpty) return false;

    final nearest = _minDistanceToRoute(currentPosition, routePoints);
    return nearest > _warningDistanceMeters;
  }

  int _nearestVertexIndex(LatLng currentPosition, List<LatLng> routePoints) {
    final distance = const Distance();
    var nearestIndex = 0;
    var nearestMeters = double.infinity;
    for (var i = 0; i < routePoints.length; i++) {
      final d = distance.as(
        LengthUnit.Meter,
        currentPosition,
        routePoints[i],
      );
      if (d < nearestMeters) {
        nearestMeters = d;
        nearestIndex = i;
      }
    }
    return nearestIndex;
  }

  double _minDistanceToRoute(LatLng currentPosition, List<LatLng> routePoints) {
    final distance = const Distance();
    var nearestMeters = double.infinity;
    for (final point in routePoints) {
      final d = distance.as(
        LengthUnit.Meter,
        currentPosition,
        point,
      );
      if (d < nearestMeters) {
        nearestMeters = d;
      }
    }
    return nearestMeters;
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '—';
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.large,
  });

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: (large ? theme.textTheme.titleMedium : theme.textTheme.labelLarge)
                  ?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
