import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/audio/presentation/widgets/floating_audio_player.dart';
import 'package:quetame_turismo/models/trail_route.dart';
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

  @override
  void dispose() {
    if (mounted) {
      context.read<RouteProvider>().clearSelectedRoute();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final routePoints = widget.route.pathPoints;
    final initialCenter = routePoints.isNotEmpty
        ? routePoints.first
        : const LatLng(4.3316, -73.8653);

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
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 14.7,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.quetame_turismo.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: AppColors.flagGreen,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
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
              ],
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
                            color: AppColors.flagGreen,
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
                    toggleUrl: widget.route.audioguideUrl,
                    trackTitle: widget.route.title,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: AppRadii.topSheet,
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.headphones,
                          color: AppColors.flagGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Audio Guias Listadas: 4',
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.flagGreen,
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
                      valueColor: const AlwaysStoppedAnimation(AppColors.flagGreen),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAudioPlayer = !_showAudioPlayer;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.flagGreen,
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
                  ],
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
        color: Color(0xFF2F3942),
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
