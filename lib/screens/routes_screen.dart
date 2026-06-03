import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/models/trail_route.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/screens/route_navigation_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  static const Map<String, LatLng> _routeStarts = {
    'la_torre': LatLng(4.3303, -73.8647),
    'paramo_burras': LatLng(4.3160, -73.8340),
  };

  static const String _downloadedRoutesKey = 'downloaded_routes_ids';
  final Set<String> _downloadedRouteIds = <String>{};
  final Set<String> _downloadingRouteIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadDownloadedRoutes();
  }

  Future<void> _loadDownloadedRoutes() async {
    final routes = context.read<RouteProvider>().routes;
    final defaultDownloadedIds = routes
        .where((route) => route.downloaded)
        .map((route) => route.id)
        .toSet();

    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList(_downloadedRoutesKey);
    final downloadedIds =
        storedIds == null ? defaultDownloadedIds : storedIds.toSet();

    if (!mounted) return;

    setState(() {
      _downloadedRouteIds
        ..clear()
        ..addAll(downloadedIds);
    });
  }

  Future<void> _downloadRoute(TrailRoute route) async {
    if (_downloadedRouteIds.contains(route.id) ||
        _downloadingRouteIds.contains(route.id)) {
      return;
    }

    setState(() => _downloadingRouteIds.add(route.id));

    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final updatedIds = <String>{..._downloadedRouteIds, route.id};
    await prefs.setStringList(_downloadedRoutesKey, updatedIds.toList());

    if (!mounted) return;

    setState(() {
      _downloadingRouteIds.remove(route.id);
      _downloadedRouteIds.add(route.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruta guardada para uso sin conexion')),
    );
  }

  Future<void> _removeDownloadedRoute(TrailRoute route) async {
    if (!_downloadedRouteIds.contains(route.id) ||
        _downloadingRouteIds.contains(route.id)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final updatedIds = <String>{..._downloadedRouteIds}..remove(route.id);
    await prefs.setStringList(_downloadedRoutesKey, updatedIds.toList());

    if (!mounted) return;

    setState(() => _downloadedRouteIds.remove(route.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga eliminada del dispositivo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<RouteProvider>().routes;
    final gps = context.watch<LocationProvider>().gpsSnapshotNotifier.value;
    final currentPosition = gps?.position;
    final speedKmh = (gps?.speedKmh ?? 0) < 2 ? 5.0 : (gps?.speedKmh ?? 0);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: routes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final route = routes[index];
        final startPoint = _routeStarts[route.id] ??
            (route.pathPoints.isNotEmpty ? route.pathPoints.first : null);
        final distanceToStartKm = _distanceToStartKm(currentPosition, startPoint);
        final etaMinutes = distanceToStartKm == null
            ? null
            : ((distanceToStartKm / speedKmh) * 60).round();
        final trailLengthKm = _routeLengthKm(route.pathPoints);
        return SizedBox(
          height: 420,
          child: RouteCard(
            route: route,
            downloaded: _downloadedRouteIds.contains(route.id),
            isDownloading: _downloadingRouteIds.contains(route.id),
            distanceToStartKm: distanceToStartKm,
            etaMinutes: etaMinutes,
            trailLengthKm: trailLengthKm,
            onDownloadPressed: () => _downloadRoute(route),
            onRemoveDownloadPressed: () => _removeDownloadedRoute(route),
            onStartRoutePressed: () {
              context.read<RouteProvider>().selectRouteForMap(route.id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteNavigationScreen(route: route),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double? _distanceToStartKm(LatLng? current, LatLng? start) {
    if (current == null || start == null) return null;
    final meters = const Distance().as(LengthUnit.Meter, current, start);
    return meters / 1000;
  }

  double _routeLengthKm(List<LatLng> points) {
    if (points.length < 2) return 0;
    final distance = const Distance();
    var meters = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      meters += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return meters / 1000;
  }
}

class RouteCard extends StatelessWidget {
  final TrailRoute route;
  final bool downloaded;
  final bool isDownloading;
  final double? distanceToStartKm;
  final int? etaMinutes;
  final double trailLengthKm;
  final VoidCallback onDownloadPressed;
  final VoidCallback onRemoveDownloadPressed;
  final VoidCallback onStartRoutePressed;

  const RouteCard({
    super.key,
    required this.route,
    required this.downloaded,
    required this.isDownloading,
    required this.distanceToStartKm,
    required this.etaMinutes,
    required this.trailLengthKm,
    required this.onDownloadPressed,
    required this.onRemoveDownloadPressed,
    required this.onStartRoutePressed,
  });

  static const Color _textOnImage = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = route.coverImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ImmersiveNetworkImage(
              imageUrl: imageUrl,
              fallbackIcon: Icons.landscape_outlined,
              placeholderColor: AppColors.goldPrimary,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black87,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.65],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _StatusChip(downloaded: downloaded),
                  const Spacer(),
                  Chip(
                    label: Text(
                      route.difficulty,
                      style: TextStyle(
                        color: route.difficultyTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: route.difficultyColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    route.title,
                    style: textTheme.titleLarge?.copyWith(
                      color: _textOnImage,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassMetricChip(
                          icon: Icons.near_me_rounded,
                          text: distanceToStartKm == null
                              ? 'A — km de ti'
                              : 'A ${distanceToStartKm!.toStringAsFixed(1)} km de ti',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GlassMetricChip(
                          icon: Icons.timer_outlined,
                          text: etaMinutes == null
                              ? 'Llegada en — min'
                              : 'Llegada en $etaMinutes min',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GlassMetricChip(
                          icon: Icons.route_rounded,
                          text: '${trailLengthKm.toStringAsFixed(1)} km sendero',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isDownloading
                              ? null
                              : (downloaded
                                  ? onRemoveDownloadPressed
                                  : onDownloadPressed),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textOnImage,
                            side: BorderSide(
                              color: _textOnImage.withValues(alpha: 0.65),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isDownloading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _textOnImage,
                                  ),
                                )
                              else
                                Icon(
                                  downloaded
                                      ? Icons.delete_outline_rounded
                                      : Icons.download_for_offline_outlined,
                                  size: 18,
                                  color: _textOnImage,
                                ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  downloaded
                                      ? 'Eliminar'
                                      : (isDownloading
                                          ? 'Descargando...'
                                          : 'Descargar'),
                                  style: const TextStyle(
                                    color: _textOnImage,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onStartRoutePressed,
                          icon: const Icon(Icons.near_me_rounded, size: 18),
                          label: const Text('Iniciar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImmersiveNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final Color placeholderColor;

  const _ImmersiveNetworkImage({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: placeholderColor,
      child: imageUrl == null
          ? Center(
              child: Icon(fallbackIcon, color: Colors.white70, size: 56),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return ColoredBox(
                  color: placeholderColor,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(fallbackIcon, color: Colors.white70, size: 56),
              ),
            ),
    );
  }
}


class _GlassMetricChip extends StatelessWidget {
  const _GlassMetricChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool downloaded;

  const _StatusChip({required this.downloaded});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        downloaded ? AppColors.goldPrimary : Colors.black54;
    return Chip(
      avatar: Icon(
        downloaded ? Icons.check_circle : Icons.download_outlined,
        color: Colors.white,
        size: 16,
      ),
      label: Text(
        downloaded ? 'Descargado' : 'Sin descarga',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
    );
  }
}
