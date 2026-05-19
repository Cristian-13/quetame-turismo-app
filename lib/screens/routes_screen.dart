import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/models/trail_route.dart';
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
    final downloadedIds = storedIds == null ? defaultDownloadedIds : storedIds.toSet();

    if (!mounted) {
      return;
    }

    setState(() {
      _downloadedRouteIds
        ..clear()
        ..addAll(downloadedIds);
    });
  }

  Future<void> _downloadRoute(TrailRoute route) async {
    if (_downloadedRouteIds.contains(route.id) || _downloadingRouteIds.contains(route.id)) {
      return;
    }

    setState(() {
      _downloadingRouteIds.add(route.id);
    });

    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final updatedIds = <String>{..._downloadedRouteIds, route.id};
    await prefs.setStringList(_downloadedRoutesKey, updatedIds.toList());

    if (!mounted) {
      return;
    }

    setState(() {
      _downloadingRouteIds.remove(route.id);
      _downloadedRouteIds.add(route.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruta guardada para uso sin conexion')),
    );
  }

  Future<void> _removeDownloadedRoute(TrailRoute route) async {
    if (!_downloadedRouteIds.contains(route.id) || _downloadingRouteIds.contains(route.id)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final updatedIds = <String>{..._downloadedRouteIds}..remove(route.id);
    await prefs.setStringList(_downloadedRoutesKey, updatedIds.toList());

    if (!mounted) {
      return;
    }

    setState(() {
      _downloadedRouteIds.remove(route.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga eliminada del dispositivo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final routes = routeProvider.routes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const separatorHeight = 14.0;
            final count = routes.length;

            final bool shouldDisableScroll = count <= 2;
            final double computedItemHeight = shouldDisableScroll && count > 0
                ? ((constraints.maxHeight - (separatorHeight * (count - 1))) / count)
                : 420.0;
            final double itemHeight = computedItemHeight.clamp(320.0, 520.0);

            return ListView.separated(
              physics: shouldDisableScroll
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              itemCount: count,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: separatorHeight),
              itemBuilder: (context, index) {
                final route = routes[index];
                return SizedBox(
                  height: shouldDisableScroll ? itemHeight : 420,
                  child: RouteCard(
                    route: route,
                    downloaded: _downloadedRouteIds.contains(route.id),
                    isDownloading: _downloadingRouteIds.contains(route.id),
                    onDownloadPressed: () => _downloadRoute(route),
                    onRemoveDownloadPressed: () => _removeDownloadedRoute(route),
                    onStartRoutePressed: () {
                      routeProvider.selectRouteForMap(route.id);
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
          },
        ),
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final TrailRoute route;
  final bool downloaded;
  final bool isDownloading;
  final VoidCallback onDownloadPressed;
  final VoidCallback onRemoveDownloadPressed;
  final VoidCallback onStartRoutePressed;

  const RouteCard({
    super.key,
    required this.route,
    required this.downloaded,
    required this.isDownloading,
    required this.onDownloadPressed,
    required this.onRemoveDownloadPressed,
    required this.onStartRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final downloadActionColor = downloaded
        ? AppColors.goldPrimary
        : colorScheme.onSurface;
    final outlineColor = colorScheme.outlineVariant;

    final isDark = theme.brightness == Brightness.dark;
    final cardBorder = BorderSide(
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      width: 1,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: theme.cardTheme.elevation ?? 4,
      shadowColor: theme.cardTheme.shadowColor,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 360;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: compact ? 3 : 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _RouteCoverImage(route: route),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _StatusChip(downloaded: downloaded),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Chip(
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
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: compact ? 5 : 6,
                child: Container(
                  color: theme.cardTheme.color ?? AppColors.cardSurface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.title,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            route.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _StatItem(
                                icon: Icons.schedule_outlined,
                                value: route.duration,
                              ),
                              _StatItem(
                                icon: Icons.terrain_outlined,
                                value: route.difficulty,
                              ),
                              _StatItem(
                                icon: Icons.place_outlined,
                                value: route.distance,
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
                                    foregroundColor: downloaded
                                        ? Colors.redAccent
                                        : downloadActionColor,
                                    side: BorderSide(
                                      color: downloaded
                                          ? Colors.redAccent
                                          : outlineColor,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
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
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      else
                                        Icon(
                                          downloaded
                                              ? Icons.delete_outline_rounded
                                              : Icons.download_for_offline_outlined,
                                          size: 18,
                                          color: downloaded
                                              ? Colors.redAccent
                                              : null,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        downloaded
                                            ? 'Eliminar descarga'
                                            : (isDownloading
                                                ? 'Descargando...'
                                                : 'Descargar'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: onStartRoutePressed,
                                  icon: const Icon(Icons.near_me_rounded),
                                  label: const Text('Iniciar ruta'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 11),
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
          );
        },
      ),
    );
  }
}

/// Imagen de portada por ruta (red) con placeholder esmeralda + spinner.
class _RouteCoverImage extends StatelessWidget {
  const _RouteCoverImage({required this.route});

  final TrailRoute route;

  static const String _laTorreUrl =
      'https://i.postimg.cc/hP7m0zhF/3a6d20af-5c24-40b5-b96f-14b0399a7781-1.jpg';
  static const String _paramoUrl =
      'https://i.postimg.cc/7ZGK0Zry/63c11546-418f-4241-a152-910aaab0ff44-1.jpg';

  static String? imageUrlFor(TrailRoute route) {
    switch (route.id) {
      case 'la_torre':
      case 'r1':
        return _laTorreUrl;
      case 'paramo_burras':
      case 'r2':
        return _paramoUrl;
    }
    final title = route.title.toLowerCase();
    if (title.contains('torre')) return _laTorreUrl;
    if (title.contains('páramo') ||
        title.contains('paramo') ||
        title.contains('burras')) {
      return _paramoUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = imageUrlFor(route);

    if (imageUrl == null) {
      return const ColoredBox(color: AppColors.goldPrimary);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.goldPrimary),
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return ColoredBox(
              color: AppColors.goldPrimary,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: AppColors.goldPrimary,
              child: Center(
                child: Icon(
                  Icons.landscape_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            );
          },
        ),
        // Degradado inferior para legibilidad de chips
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x66000000),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool downloaded;

  const _StatusChip({required this.downloaded});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color bgColor =
        downloaded ? AppColors.goldPrimary : scheme.onSurfaceVariant;
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

