import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/audio/presentation/widgets/floating_audio_player.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/directional_user_marker.dart';
import 'package:quetame_turismo/models/trail_route.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

class RouteNavigationScreen extends StatefulWidget {
  final TrailRoute route;

  const RouteNavigationScreen({
    super.key,
    required this.route,
  });

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen> {
  bool _showAudioPlayer = false;
  final MapController _mapController = MapController();
  StreamSubscription<CompassEvent>? _compassSub;
  double? _compassHeading;
  DateTime? _lastCameraUpdateAt;
  late final LocationProvider _locationProvider;
  late final RouteProvider _routeProvider;

  static const double _followZoom = 16.6;
  static const Duration _cameraThrottle = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    _locationProvider = context.read<LocationProvider>();
    _routeProvider = context.read<RouteProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _routeProvider.setActivePlaceRoute(widget.route.pathPoints);
      _locationProvider.gpsSnapshotNotifier.addListener(_onGpsUpdate);
    });
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _locationProvider.gpsSnapshotNotifier.removeListener(_onGpsUpdate);
    _routeProvider.clearSelectedRoute();
    _routeProvider.clearActivePlaceRoute();
    super.dispose();
  }

  void _onGpsUpdate() {
    if (!mounted) return;
    final gps = _locationProvider.gpsSnapshotNotifier.value;
    if (gps == null) return;
    _routeProvider.advanceRoute(gps.position);
    _moveCamera(gps.position, _resolvedHeading(gps.headingDegrees));
    setState(() {});
  }

  void _moveCamera(LatLng position, double? heading) {
    final now = DateTime.now();
    if (_lastCameraUpdateAt != null &&
        now.difference(_lastCameraUpdateAt!) < _cameraThrottle) {
      return;
    }
    _lastCameraUpdateAt = now;
    if (!_mapController.camera.visibleBounds.contains(position)) {
      _mapController.move(position, _followZoom);
    } else {
      _mapController.move(position, _mapController.camera.zoom);
    }
    if (heading != null) {
      _mapController.rotate(heading);
    }
  }

  void _startCompass() {
    final events = FlutterCompass.events;
    if (events == null) return;
    _compassSub = events.listen((event) {
      if (!mounted) return;
      if (event.heading == null) return;
      setState(() {
        _compassHeading = event.heading;
      });
    });
  }

  double? _resolvedHeading(double? gpsHeading) {
    if (gpsHeading != null && gpsHeading >= 0) return gpsHeading;
    return _compassHeading;
  }

  double? _remainingKm(LatLng? current, List<LatLng> routePoints) {
    if (current == null || routePoints.isEmpty) return null;
    final distance = const Distance();
    var nearestIndex = 0;
    var nearestMeters = double.infinity;
    for (var i = 0; i < routePoints.length; i++) {
      final d = distance.as(LengthUnit.Meter, current, routePoints[i]);
      if (d < nearestMeters) {
        nearestMeters = d;
        nearestIndex = i;
      }
    }
    var total = nearestMeters;
    for (var i = nearestIndex; i < routePoints.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, routePoints[i], routePoints[i + 1]);
    }
    return total / 1000;
  }

  void _finishRouteAndExit() {
    _routeProvider.clearActivePlaceRoute();
    _routeProvider.clearSelectedRoute();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locationProvider = context.watch<LocationProvider>();
    final routeProvider = context.watch<RouteProvider>();
    final gps = locationProvider.gpsSnapshotNotifier.value;
    final routePoints = routeProvider.activePlaceRoute.isNotEmpty
        ? routeProvider.activePlaceRoute
        : widget.route.pathPoints;
    final initialCenter = routePoints.isNotEmpty
        ? routePoints.first
        : const LatLng(4.3316, -73.8653);
    final userPos = gps?.position;
    final heading = _resolvedHeading(gps?.headingDegrees);
    final remainingKm = _remainingKm(userPos, routePoints);
    final speedKmh = gps?.speedKmh ?? 0;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<RouteProvider>().clearSelectedRoute();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 14.7,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png',
                  userAgentPackageName: 'com.quetame_turismo.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: AppColors.goldPrimary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (userPos != null)
                      Marker(
                        point: userPos,
                        width: 72,
                        height: 72,
                        child: DirectionalUserMarker(
                          headingDegrees: heading,
                          accuracyMeters: gps?.accuracyMeters ?? 12,
                        ),
                      ),
                    Marker(
                      point: routePoints.length > 1 ? routePoints[1] : initialCenter,
                      width: 36,
                      height: 36,
                      child: _GuideMarker(icon: Icons.headphones),
                    ),
                    Marker(
                      point: routePoints.length > 2 ? routePoints[2] : initialCenter,
                      width: 36,
                      height: 36,
                      child: _GuideMarker(icon: Icons.headphones),
                    ),
                    Marker(
                      point: routePoints.length > 4 ? routePoints[4] : initialCenter,
                      width: 38,
                      height: 38,
                      child: _GuideMarker(icon: Icons.flag),
                    ),
                  ],
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© CARTO'),
                  ],
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.goldPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.place_rounded,
                        label: 'Distancia',
                        value: remainingKm == null
                            ? '—'
                            : '${remainingKm.toStringAsFixed(1)} km',
                      ),
                    ),
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.speed_rounded,
                        label: 'Velocidad',
                        value: '${speedKmh.toStringAsFixed(0)} km/h',
                      ),
                    ),
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.explore_rounded,
                        label: 'Rumbo',
                        value: heading == null
                            ? '—'
                            : '${heading.toStringAsFixed(0)}°',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.read<RouteProvider>().clearSelectedRoute();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: scheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: AppRadii.md,
                          boxShadow: AppShadows.soft,
                        ),
                        child: Text(
                          'Navegando: ${widget.route.title}',
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.goldPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 140,
              child: AnimatedOpacity(
                opacity: _showAudioPlayer ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: IgnorePointer(
                  ignoring: !_showAudioPlayer,
                  child: FloatingAudioPlayer(
                    routeId: widget.route.id,
                    toggleUrl: widget.route.audioUrl,
                    trackTitle: widget.route.title,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: AppRadii.topSheet,
                    boxShadow: AppShadows.soft,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.headphones,
                              color: AppColors.goldPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Audio Guias Listadas: 4',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: AppColors.goldPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '2.5 km de 8.5 km',
                              style: AppTextStyles.bodyMuted.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: 2.5 / 8.5,
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation(AppColors.goldPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showAudioPlayer = !_showAudioPlayer;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.md,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  _showAudioPlayer
                                      ? 'Ocultar Reproductor'
                                      : 'Ver Detalles de Audio Guias',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _finishRouteAndExit,
                              icon: const Icon(Icons.flag_rounded, size: 18),
                              label: const Text('Finalizar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: scheme.onSurface,
                                side: BorderSide(
                                  color: scheme.onSurface.withValues(alpha: 0.28),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.md,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideMarker extends StatelessWidget {
  final IconData icon;

  const _GuideMarker({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.goldDeep,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.goldPrimary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
