import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/map/data/osrm_route_service.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/categories_legend_card.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
import 'package:quetame_turismo/screens/place_detail_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);
  static const double _defaultMapZoom = 14.0;
  final MapController _mapController = MapController();

  AnimationController? _cameraAnim;

  /// Filtro de categorías: 'Todos' o categoría normalizada desde Firestore.
  String selectedCategory = 'Todos';

  @override
  void dispose() {
    _cameraAnim?.dispose();
    super.dispose();
  }

  void _removeRouteAndResetOverview() {
    context.read<RouteProvider>().clearActivePlaceRoute();
    _cameraAnim?.dispose();
    _cameraAnim = null;
    _runCameraAnimation(_quetameCenter, _defaultMapZoom);
  }

  Future<void> _setRouteToSite(_FirestoreSite site) async {
    final messenger = ScaffoldMessenger.of(context);
    final locationProvider = context.read<LocationProvider>();
    final routeProvider = context.read<RouteProvider>();

    await locationProvider.refreshLocationState();
    final current = locationProvider.currentLocation;
    if (current == null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Activa tu ubicación para fijar la ruta.'),
          ),
        );
      return;
    }

    final destination = LatLng(site.latitud, site.longitud);
    try {
      final route = await OsrmRouteService.fetchDrivingRoute(
        origin: current,
        destination: destination,
      );
      final routePoints = route.isEmpty ? <LatLng>[current, destination] : route;
      routeProvider.setActivePlaceRoute(routePoints);
      _animateCameraToInclude(routePoints);
    } catch (_) {
      routeProvider.setActivePlaceRoute(<LatLng>[current, destination]);
      _animateCameraToInclude(<LatLng>[current, destination]);
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('No se pudo calcular la ruta exacta. Se mostró una línea base.'),
          ),
        );
    }
  }

  void _animateCameraToInclude(List<LatLng> points) {
    if (points.isEmpty || !mounted) return;

    final bounds = LatLngBounds.fromPoints(points);
    final cam = _mapController.camera;
    final targetCam = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.fromLTRB(44, 100, 44, 140),
    ).fit(cam);

    _runCameraAnimation(targetCam.center, targetCam.zoom);
  }

  List<_FirestoreSite> _sitesForFilter(List<_FirestoreSite> all) {
    if (selectedCategory == 'Todos') return all;
    return all.where((p) => p.category == selectedCategory).toList();
  }

  void _fitCameraToFilteredSites(String category, List<_FirestoreSite> all) {
    final filtered = category == 'Todos'
        ? all
        : all.where((p) => p.category == category).toList();
    final points =
        filtered.map((p) => LatLng(p.latitud, p.longitud)).toList();
    if (points.isEmpty) {
      _runCameraAnimation(_quetameCenter, _defaultMapZoom);
      return;
    }
    if (points.length == 1) {
      _runCameraAnimation(points.first, 15.2);
      return;
    }
    _animateCameraToInclude(points);
  }

  void _onCategorySelected(String category, List<_FirestoreSite> allSites) {
    setState(() => selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitCameraToFilteredSites(category, allSites);
    });
  }

  void _runCameraAnimation(LatLng endCenter, double endZoom) {
    if (!mounted) return;

    final cam = _mapController.camera;
    _cameraAnim?.dispose();
    _cameraAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final startCenter = cam.center;
    final startZoom = cam.zoom;

    void tick() {
      final v = Curves.easeInOutCubic.transform(_cameraAnim!.value);
      final lat =
          startCenter.latitude + (endCenter.latitude - startCenter.latitude) * v;
      final lng = startCenter.longitude +
          (endCenter.longitude - startCenter.longitude) * v;
      final zoom = startZoom + (endZoom - startZoom) * v;
      _mapController.move(LatLng(lat, lng), zoom);
    }

    _cameraAnim!.addListener(tick);
    _cameraAnim!.forward().whenComplete(() {
      if (_cameraAnim != null) {
        _cameraAnim!.removeListener(tick);
        _cameraAnim!.dispose();
        _cameraAnim = null;
      }
    });
  }

  void _showSiteBottomSheet(_FirestoreSite site) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        final textTheme = Theme.of(context).textTheme;
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: Image.network(
                      site.imagenUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(strokeWidth: 2.2),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  site.nombre,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  site.descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _setRouteToSite(site);
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Fijar Ruta'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(
                                place: site.toPlaceModel(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.flagGreen,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Ver Detalles'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleMyLocationPressed() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.refreshLocationState();

    if (!mounted) return;

    if (!locationProvider.isLocationServiceEnabled) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text('El GPS está apagado'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Encender',
              textColor: Colors.white,
              onPressed: Geolocator.openLocationSettings,
            ),
          ),
        );
      return;
    }

    if (locationProvider.permission == LocationPermission.denied) {
      await locationProvider.requestPermissionAgain();
      if (!mounted) return;
    }

    if (locationProvider.permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Necesitamos permisos para guiarte en los senderos.',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Abrir Ajustes',
              textColor: Colors.white,
              onPressed: Geolocator.openAppSettings,
            ),
          ),
        );
      return;
    }

    final current = locationProvider.currentLocation;
    if (current != null) {
      _mapController.move(current, 15.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final locationProvider = context.watch<LocationProvider>();
    final userLocation = locationProvider.currentLocation;
    final geoRoutes = context.watch<RouteProvider>().visibleGeoRoutesOnMainMap;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('sitios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error al cargar sitios: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final sites = snapshot.data?.docs
                .map((doc) => _FirestoreSite.fromMap(doc.id, doc.data()))
                .whereType<_FirestoreSite>()
                .toList() ??
            <_FirestoreSite>[];
        final filteredSites = _sitesForFilter(sites);

        final markers = [
          ...filteredSites.map(
            (site) => Marker(
              width: 36,
              height: 36,
              point: LatLng(site.latitud, site.longitud),
              child: GestureDetector(
                onTap: () => _showSiteBottomSheet(site),
                child: _MapPin(
                  color: CategoriesLegendCard.dotColorForLabel(site.category),
                ),
              ),
            ),
          ),
          if (userLocation != null)
            Marker(
              width: 24,
              height: 24,
              point: userLocation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
        ];

        return Stack(
          children: [
            FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: _quetameCenter,
            initialZoom: _defaultMapZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.quetame_turismo.app',
            ),
            if (geoRoutes.isNotEmpty)
              PolylineLayer(
                polylines: [
                  for (final path in geoRoutes)
                    Polyline(
                      points: path,
                      strokeWidth: 4.0,
                      color: Colors.redAccent,
                    ),
                ],
              ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.of(context).padding.top + 8,
          child: SizedBox(
            height: 44,
            child: CategoriesLegendCard(
              isDarkMode: isDarkMode,
              selectedCategory: selectedCategory,
              onCategorySelected: (category) =>
                  _onCategorySelected(category, sites),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'map_reset_view',
                onPressed: _removeRouteAndResetOverview,
                tooltip: 'Restablecer vista',
                child: const Icon(Icons.center_focus_strong_rounded),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'map_my_location',
                onPressed: _handleMyLocationPressed,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
          ],
        );
      },
    );
  }
}

class _FirestoreSite {
  final String id;
  final String nombre;
  final String descripcion;
  final String historia;
  final String horarios;
  final String horaApertura;
  final String horaCierre;
  final String telefono;
  final String menuUrl;
  final String categoriaRaw;
  final String category;
  final String imagenUrl;
  final double latitud;
  final double longitud;

  const _FirestoreSite({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.historia,
    required this.horarios,
    required this.horaApertura,
    required this.horaCierre,
    required this.telefono,
    required this.menuUrl,
    required this.categoriaRaw,
    required this.category,
    required this.imagenUrl,
    required this.latitud,
    required this.longitud,
  });

  static _FirestoreSite? fromMap(String docId, Map<String, dynamic> data) {
    final nombre = (data['nombre'] ?? '').toString().trim();
    final descripcion = (data['descripcion'] ?? '').toString().trim();
    final historia = (data['historia'] ?? '').toString().trim();
    final horarios = (data['horarios'] ?? '').toString().trim();
    final horaApertura = (data['hora_apertura'] ?? '').toString().trim();
    final horaCierre = (data['hora_cierre'] ?? '').toString().trim();
    final telefono =
        (data['telefono'] ?? data['phone'] ?? '').toString().trim();
    final menuUrl = (data['menu_url'] ?? '').toString().trim();
    final categoriaRaw = (data['categoria'] ?? '').toString();
    final imagenUrl = (data['imagen_url'] ?? '').toString().trim();
    final lat = data['latitud'];
    final lng = data['longitud'];

    if (nombre.isEmpty || lat == null || lng == null) {
      return null;
    }

    final latitud = lat is num ? lat.toDouble() : double.tryParse('$lat');
    final longitud = lng is num ? lng.toDouble() : double.tryParse('$lng');
    if (latitud == null || longitud == null) {
      return null;
    }

    return _FirestoreSite(
      id: docId,
      nombre: nombre,
      descripcion: descripcion,
      historia: historia,
      horarios: horarios,
      horaApertura: horaApertura,
      horaCierre: horaCierre,
      telefono: telefono,
      menuUrl: menuUrl,
      categoriaRaw: categoriaRaw,
      category: _normalizeCategory(categoriaRaw),
      imagenUrl: imagenUrl,
      latitud: latitud,
      longitud: longitud,
    );
  }

  PlaceModel toPlaceModel() {
    return PlaceModel(
      id: id,
      name: nombre,
      description: descripcion,
      category: _toPlaceCategory(category),
      rawCategory: categoriaRaw,
      imageUrl: imagenUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=60'
          : imagenUrl,
      latitude: latitud,
      longitude: longitud,
      phone: telefono.isEmpty ? null : telefono,
      historia: historia,
      horarios: horarios,
      horaApertura: horaApertura.isEmpty ? null : horaApertura,
      horaCierre: horaCierre.isEmpty ? null : horaCierre,
      menuUrl: menuUrl.isEmpty ? null : menuUrl,
    );
  }
}

String _normalizeCategory(String raw) {
  final value = raw.trim().toLowerCase();
  switch (value) {
    case 'historia':
      return 'Historia';
    case 'naturaleza':
      return 'Naturaleza';
    case 'mirador':
      return 'Mirador';
    case 'gastronomia':
    case 'gastronomía':
    case 'restaurante':
    case 'comida':
      return 'Gastronomía';
    default:
      return 'Naturaleza';
  }
}

PlaceCategory _toPlaceCategory(String category) {
  switch (category) {
    case 'Historia':
      return PlaceCategory.historia;
    case 'Mirador':
      return PlaceCategory.mirador;
    case 'Gastronomía':
      return PlaceCategory.gastronomia;
    case 'Naturaleza':
    default:
      return PlaceCategory.naturaleza;
  }
}

class _MapPin extends StatelessWidget {
  final Color color;

  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.place,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
