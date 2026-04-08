import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/map/data/osrm_route_service.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/categories_legend_card.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/place_bottom_sheet.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/place_provider.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
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

  List<LatLng> _routePolyline = [];
  AnimationController? _cameraAnim;
  bool _routingBusy = false;

  /// Filtro de categorías: 'Todos' o el [PlaceCategory.label] (Historia, Naturaleza, Mirador).
  String selectedCategory = 'Todos';

  @override
  void dispose() {
    _cameraAnim?.dispose();
    super.dispose();
  }

  void _removeRouteAndResetOverview() {
    _cameraAnim?.dispose();
    _cameraAnim = null;
    setState(() => _routePolyline = []);
    _runCameraAnimation(_quetameCenter, _defaultMapZoom);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryTerracotta,
        ),
      );
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

  List<PlaceModel> _placesForFilter(List<PlaceModel> all) {
    if (selectedCategory == 'Todos') return all;
    return all.where((p) => p.category.label == selectedCategory).toList();
  }

  void _fitCameraToFilteredPlaces(String category) {
    final all = context.read<PlaceProvider>().places;
    final filtered = category == 'Todos'
        ? all
        : all.where((p) => p.category.label == category).toList();
    final points =
        filtered.map((p) => LatLng(p.latitude, p.longitude)).toList();
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

  void _onCategorySelected(String category) {
    setState(() => selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitCameraToFilteredPlaces(category);
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

  Future<void> _onPlaceRutaPressed(PlaceModel place) async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.refreshLocationState();
    if (!mounted) return;

    if (!locationProvider.isLocationServiceEnabled) {
      _snack('Activa el GPS para trazar la ruta');
      return;
    }

    if (locationProvider.permission == LocationPermission.denied) {
      await locationProvider.requestPermissionAgain();
      if (!mounted) return;
    }

    if (locationProvider.permission == LocationPermission.deniedForever ||
        locationProvider.permission == LocationPermission.denied) {
      _snack('Necesitamos tu ubicación para calcular la ruta');
      return;
    }

    LatLng? user = locationProvider.currentLocation;
    if (user == null) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        user = LatLng(pos.latitude, pos.longitude);
      } catch (_) {
        _snack('No se pudo obtener tu ubicación');
        return;
      }
    }

    setState(() => _routingBusy = true);

    try {
      final dest = LatLng(place.latitude, place.longitude);
      final points = await OsrmRouteService.fetchDrivingRoute(
        origin: user,
        destination: dest,
      );
      if (!mounted) return;

      if (points.isEmpty) {
        setState(() => _routingBusy = false);
        _snack('No se pudo calcular la ruta');
        return;
      }

      final boundsPoints = [...points, user, dest];

      setState(() {
        _routePolyline = points;
        _routingBusy = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animateCameraToInclude(boundsPoints);
      });
    } on OsrmRouteException catch (e) {
      if (mounted) {
        setState(() => _routingBusy = false);
        _snack(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _routingBusy = false);
        _snack('Error al obtener la ruta');
      }
    }
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
            backgroundColor: AppColors.primaryTerracotta,
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
            backgroundColor: AppColors.primaryTerracotta,
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
    final places = context.watch<PlaceProvider>().places;
    final filteredPlaces = _placesForFilter(places);
    final locationProvider = context.watch<LocationProvider>();
    final userLocation = locationProvider.currentLocation;

    final markers = [
      ...filteredPlaces.map(
        (place) => Marker(
          width: 36,
          height: 36,
          point: LatLng(place.latitude, place.longitude),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => PlaceBottomSheet(
                  place: place,
                  onRutaPressed: _onPlaceRutaPressed,
                ),
              );
            },
            child: _MapPin(color: place.category.color),
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
            if (_routePolyline.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePolyline,
                    strokeWidth: 5,
                    color: Colors.blue,
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
          bottom: 24,
          child: CategoriesLegendCard(
            isDarkMode: isDarkMode,
            selectedCategory: selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_routePolyline.isNotEmpty) ...[
                FloatingActionButton.small(
                  heroTag: 'map_clear_route',
                  onPressed: _removeRouteAndResetOverview,
                  tooltip: 'Quitar ruta',
                  child: const Icon(Icons.close_rounded),
                ),
                const SizedBox(height: 12),
              ],
              FloatingActionButton(
                heroTag: 'map_my_location',
                onPressed: _handleMyLocationPressed,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        if (_routingBusy)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(height: 12),
                        Text('Calculando ruta…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
