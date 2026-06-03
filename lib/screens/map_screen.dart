import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/map/data/map_entity_catalog.dart';
import 'package:quetame_turismo/features/map/data/osrm_route_service.dart';
import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/presentation/map_camera_animator.dart';
import 'package:quetame_turismo/features/map/presentation/map_navigation_controller.dart';
import 'package:quetame_turismo/features/map/presentation/map_view_model.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_canvas.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_category_filter_bar.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_icon_button.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_navigation_hud.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_search_overlay.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_sites_panel.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/screens/place_detail_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class MapScreen extends StatefulWidget {
  final String? initialCategory;

  const MapScreen({super.key, this.initialCategory});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);
  static const double _defaultMapZoom = 14.0;
  static const double _sheetMinSize = 0.11;
  static const double _sheetDetailSize = 0.52;
  static const double _sheetMaxSize = 0.88;
  static const double _floatingControlsGap = 16;

  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final MapViewModel _viewModel = MapViewModel();

  late final MapCameraAnimator _cameraAnimator;
  late final MapNavigationController _navigation;

  final GlobalKey _searchOverlayKey = GlobalKey();
  double _searchOverlayHeight = 120;
  static const double _hudHideSheetThreshold = 0.45;

  late final AnimationController _hudFadeController;

  Timer? _searchDebounce;
  bool _isComputingRoute = false;
  String _firestoreSignature = '';
  List<MapEntity> _cachedEntities = const <MapEntity>[];

  @override
  void initState() {
    super.initState();
    _viewModel.setFilter(_resolveInitialFilter(widget.initialCategory));
    _cameraAnimator = MapCameraAnimator(
      mapController: _mapController,
      vsync: this,
    );
    _navigation = MapNavigationController(
      mapController: _mapController,
      cameraAnimator: _cameraAnimator,
      locationProvider: context.read<LocationProvider>(),
      routeProvider: context.read<RouteProvider>(),
    );
    _sheetController.addListener(_handleSheetControllerTick);
    _viewModel.addListener(_scheduleMeasureSearchOverlay);

    _hudFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSearchOverlay());
  }

  void _scheduleMeasureSearchOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSearchOverlay());
  }

  void _measureSearchOverlay() {
    final renderBox =
        _searchOverlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;

    final measured = renderBox.size.height + 16;
    if ((measured - _searchOverlayHeight).abs() > 1) {
      setState(() => _searchOverlayHeight = measured);
    }
  }

  void _onSheetSizeChanged(double size) {
    if (size > _hudHideSheetThreshold) {
      if (_hudFadeController.status != AnimationStatus.completed &&
          _hudFadeController.status != AnimationStatus.forward) {
        _hudFadeController.forward();
      }
    } else {
      if (_hudFadeController.status != AnimationStatus.dismissed &&
          _hudFadeController.status != AnimationStatus.reverse) {
        _hudFadeController.reverse();
      }
    }
  }

  void _handleSheetControllerTick() {
    if (!_sheetController.isAttached) return;
    _onSheetSizeChanged(_sheetController.size);
  }

  @override
  void dispose() {
    final routeProvider = context.read<RouteProvider>();
    routeProvider.clearActivePlaceRoute();
    routeProvider.clearSelectedRoute();
    _viewModel.removeListener(_scheduleMeasureSearchOverlay);
    _searchDebounce?.cancel();
    _searchController.dispose();
    _hudFadeController.dispose();
    _navigation.dispose();
    _cameraAnimator.dispose();
    _sheetController.removeListener(_handleSheetControllerTick);
    _sheetController.dispose();
    super.dispose();
  }

  String _resolveInitialFilter(String? category) {
    if (category == null || category == 'Todos') return 'Todos';
    return category;
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _viewModel.setSearchQuery('');
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _viewModel.setSearchQuery(trimmed);
    });
  }

  void _fitCameraToVisibleEntities() {
    final filtered = _viewModel.filteredEntities;
    final points = filtered.map((e) => e.latLng).toList();
    if (points.isEmpty) {
      _animatedMove(_quetameCenter, _defaultMapZoom);
      return;
    }
    if (points.length == 1) {
      _animatedMove(points.first, 15.2);
      return;
    }
    _animateCameraToInclude(points);
  }

  void _onFilterSelected(String filterId) {
    _viewModel.setFilter(filterId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitCameraToVisibleEntities();
      _animateSheetTo(_sheetMinSize);
    });
  }

  void _onEntitySelected(MapEntity entity) {
    _searchController.text = entity.name;
    _viewModel.setSearchQuery(entity.name);
    _viewModel.selectEntity(entity);
    _navigation.setNavigationDestination(entity);
    _animatedMove(entity.latLng, 16.2);
    _animateSheetTo(_sheetDetailSize);
  }

  void _clearSelection() {
    _viewModel.clearSelection();
    _navigation.setNavigationDestination(null);
    _animateSheetTo(_sheetMinSize);
  }

  Future<void> _finishActiveRoute({bool askConfirmation = true}) async {
    final routeProvider = context.read<RouteProvider>();
    if (!routeProvider.hasActivePlaceRoute) return;

    if (askConfirmation) {
      final shouldFinish = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Finalizar ruta'),
          content: const Text(
            'Se eliminará el recorrido actual y la guía activa del mapa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
      if (shouldFinish != true) return;
    }

    routeProvider.clearActivePlaceRoute();
    routeProvider.clearSelectedRoute();
    _navigation.setNavigationDestination(null);
    _clearSelection();

    if (!mounted || !askConfirmation) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruta finalizada correctamente.')),
    );
  }

  Future<void> _animateSheetTo(double size) async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _animatedMove(LatLng target, double zoom, {double? rotation}) {
    _cameraAnimator.animatedMapMove(
      target: target,
      zoom: zoom,
      rotation: rotation,
    );
  }

  void _animateCameraToInclude(List<LatLng> points) {
    if (points.isEmpty || !mounted) return;

    final bounds = LatLngBounds.fromPoints(points);
    final cam = _mapController.camera;
    final topPad = MediaQuery.of(context).padding.top +
        _searchOverlayHeight +
        72;
    final targetCam = CameraFit.bounds(
      bounds: bounds,
      padding: EdgeInsets.fromLTRB(48, topPad, 48, 220),
    ).fit(cam);

    _animatedMove(targetCam.center, targetCam.zoom);
  }

  Future<void> _setRouteToEntity(MapEntity entity) async {
    if (_isComputingRoute) return;
    final messenger = ScaffoldMessenger.of(context);
    final locationProvider = context.read<LocationProvider>();
    final routeProvider = context.read<RouteProvider>();
    setState(() => _isComputingRoute = true);

    await locationProvider.refreshLocationState();
    final current = locationProvider.currentLocation;
    if (current == null) {
      if (mounted) setState(() => _isComputingRoute = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Activa tu ubicación para fijar la ruta.'),
        ),
      );
      return;
    }

    _navigation.setNavigationDestination(entity);

    final destination = entity.latLng;
    try {
      final route = await OsrmRouteService.fetchDrivingRoute(
        origin: current,
        destination: destination,
      );
      final routePoints =
          route.isEmpty ? <LatLng>[current, destination] : route;
      routeProvider.setActivePlaceRoute(routePoints);
      _animateCameraToInclude(routePoints);
    } catch (_) {
      routeProvider.setActivePlaceRoute(<LatLng>[current, destination]);
      _animateCameraToInclude(<LatLng>[current, destination]);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo calcular la ruta exacta. Se mostró una línea base.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isComputingRoute = false);
    }
  }

  List<MapEntity> _resolveEntitiesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final docs = snapshot.docs;
    final signature = docs
        .map(
          (doc) =>
              '${doc.id}|${doc.data()['nombre'] ?? ''}|${doc.data()['latitud'] ?? ''}|${doc.data()['longitud'] ?? ''}|${doc.data()['categoria'] ?? ''}|${doc.data()['imagen_url'] ?? ''}',
        )
        .join('||');
    if (signature == _firestoreSignature && _cachedEntities.isNotEmpty) {
      return _cachedEntities;
    }

    final firestoreSites = docs
        .map((doc) => FirestoreMapSite.fromMap(doc.id, doc.data()))
        .whereType<FirestoreMapSite>()
        .toList(growable: false);
    final entities = MapEntityCatalog.buildFromFirestoreSites(firestoreSites);
    _firestoreSignature = signature;
    _cachedEntities = entities;
    return entities;
  }

  Future<void> _ensureLocationReady() async {
    final locationProvider = context.read<LocationProvider>();
    final scheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    await locationProvider.refreshLocationState();
    if (!mounted) return;

    if (!locationProvider.isLocationServiceEnabled) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('El GPS está apagado'),
          backgroundColor: scheme.primary,
          action: SnackBarAction(
            label: 'Encender',
            onPressed: Geolocator.openLocationSettings,
          ),
        ),
      );
      return;
    }

    if (locationProvider.permission == LocationPermission.denied) {
      await locationProvider.requestPermissionAgain();
    }

    if (locationProvider.permission == LocationPermission.deniedForever) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Necesitamos permisos para guiarte en los senderos.',
          ),
          backgroundColor: scheme.primary,
          action: SnackBarAction(
            label: 'Abrir Ajustes',
            onPressed: Geolocator.openAppSettings,
          ),
        ),
      );
    }
  }

  void _openPlaceDetails(MapEntity entity) {
    final place = entity.toPlaceModel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(place: place),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.read<LocationProvider>();
    final routeProvider = context.watch<RouteProvider>();
    final geoRoutes = routeProvider.visibleGeoRoutesOnMainMap;
    final hasActivePlaceRoute = routeProvider.hasActivePlaceRoute;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('sitios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.goldPrimary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Text(
                'Error al cargar sitios: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data != null) {
          _viewModel.setEntities(_resolveEntitiesFromSnapshot(data));
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              Positioned.fill(
                child: MapCanvas(
                  mapController: _mapController,
                  viewModel: _viewModel,
                  gpsSnapshot: locationProvider.gpsSnapshotNotifier,
                  geoRoutes: geoRoutes,
                  navigationController: _navigation,
                  onEntityTap: _onEntitySelected,
                ),
              ),
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    key: _searchOverlayKey,
                    child: MapSearchOverlay(
                      viewModel: _viewModel,
                      searchController: _searchController,
                      onSearchChanged: _onSearchChanged,
                      onSuggestionSelected: _onEntitySelected,
                      categoryBar: ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) => MapCategoryFilterBar(
                          selectedFilterId: _viewModel.selectedFilterId,
                          onFilterSelected: _onFilterSelected,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top +
                    _searchOverlayHeight +
                    8,
                left: 16,
                right: 16,
                child: AnimatedBuilder(
                  animation: _hudFadeController,
                  builder: (context, child) => IgnorePointer(
                    ignoring: _hudFadeController.value < 0.05,
                    child: Opacity(
                      opacity: _hudFadeController.value,
                      child: child,
                    ),
                  ),
                  child: ListenableBuilder(
                    listenable: _navigation,
                    builder: (context, _) {
                      final showHud =
                          _navigation.followMode == MapCameraFollowMode.tracking ||
                              hasActivePlaceRoute;
                      if (!showHud) return const SizedBox.shrink();
                      return const MapNavigationHud();
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListenableBuilder(
                      listenable: _sheetController,
                      builder: (context, _) {
                        final sheetFraction = _sheetController.isAttached
                            ? _sheetController.size
                            : _sheetMinSize;
                        final sheetTopFromBottom =
                            constraints.maxHeight * sheetFraction;
                        final controlsBottom =
                            sheetTopFromBottom + bottomInset + _floatingControlsGap;
                        final controlsTop = MediaQuery.of(context).padding.top +
                            _searchOverlayHeight +
                            _floatingControlsGap;

                        return Padding(
                          padding: EdgeInsets.only(
                            top: controlsTop,
                            right: 16,
                            bottom: controlsBottom,
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ListenableBuilder(
                              listenable: _navigation,
                              builder: (context, _) {
                                final isTracking = _navigation.followMode ==
                                    MapCameraFollowMode.tracking;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (_navigation.needsRecenter)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: FilledButton.icon(
                                          onPressed: _navigation.recenterOnUser,
                                          icon: const Icon(
                                            Icons.gps_fixed_rounded,
                                            size: 18,
                                          ),
                                          label: const Text('Re-centrar'),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.goldPrimary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                    MapGlassIconButton(
                                      icon: _navigation.compassMode
                                          ? Icons.explore_rounded
                                          : Icons.explore_outlined,
                                      tooltip: 'Modo brújula',
                                      compact: true,
                                      onPressed: () async {
                                        await _ensureLocationReady();
                                        await _navigation.toggleCompassMode();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    MapGlassIconButton(
                                      icon: isTracking
                                          ? Icons.navigation_rounded
                                          : Icons.navigation_outlined,
                                      tooltip: isTracking
                                          ? 'Modo seguimiento activo'
                                          : 'Activar seguimiento',
                                      compact: true,
                                      onPressed: () async {
                                        await _ensureLocationReady();
                                        _navigation.toggleFollowMode();
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    MapGlassIconButton(
                                      icon: Icons.location_city_rounded,
                                      tooltip: 'Centrar pueblo',
                                      compact: true,
                                      onPressed: () =>
                                          _animatedMove(_quetameCenter, _defaultMapZoom),
                                    ),
                                    if (hasActivePlaceRoute) ...[
                                      const SizedBox(height: 10),
                                      MapGlassIconButton(
                                        icon: Icons.close_rounded,
                                        tooltip: 'Finalizar ruta',
                                        compact: true,
                                        onPressed: _finishActiveRoute,
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (hasActivePlaceRoute)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12 + bottomInset,
                  child: SafeArea(
                    top: false,
                    child: FilledButton.icon(
                      onPressed: _finishActiveRoute,
                      icon: const Icon(Icons.flag_rounded, size: 18),
                      label: const Text('Finalizar ruta'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.82),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final filtered = _viewModel.filteredEntities;
                  MapEntity? selected = _viewModel.selectedEntity;
                  if (selected != null &&
                      !filtered.any((e) => e.id == selected!.id)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _clearSelection();
                    });
                    selected = null;
                  }

                  final active = selected;

                  return DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: _sheetMinSize,
                    minChildSize: _sheetMinSize,
                    maxChildSize: _sheetMaxSize,
                    snap: true,
                    snapSizes: const [
                      _sheetMinSize,
                      _sheetDetailSize,
                      _sheetMaxSize,
                    ],
                    builder: (context, scrollController) {
                      return MapSitesPanel(
                        scrollController: scrollController,
                        entities: filtered,
                        selectedEntity: active,
                        onEntitySelected: _onEntitySelected,
                        onGoToPlace: active == null
                            ? () {}
                            : (_isComputingRoute
                                ? () {}
                                : () => _setRouteToEntity(active)),
                        onViewDetails: active == null
                            ? () {}
                            : () => _openPlaceDetails(active),
                        onClearSelection: _clearSelection,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
