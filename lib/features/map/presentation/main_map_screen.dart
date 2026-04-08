import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/categories_legend_card.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_header.dart';
import 'package:quetame_turismo/models/map_marker.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';
  final MapController _mapController = MapController();
  AnimationController? _cameraAnim;

  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);
  static const double _defaultZoom = 14.0;

  static const List<MapMarker> _markers = [
    MapMarker(
      id: 'm1',
      position: LatLng(4.3330, -73.8667),
      category: 'Historia',
      color: Color(0xFF8A4B22),
    ),
    MapMarker(
      id: 'm2',
      position: LatLng(4.3327, -73.8633),
      category: 'Mirador',
      color: Color(0xFF4D74D9),
    ),
    MapMarker(
      id: 'm3',
      position: LatLng(4.3302, -73.8650),
      category: 'Naturaleza',
      color: Color(0xFF3FA63A),
    ),
    MapMarker(
      id: 'm4',
      position: LatLng(4.3298, -73.8618),
      category: 'Gastronomía',
      color: Color(0xFFF15A4A),
    ),
  ];

  @override
  void dispose() {
    _cameraAnim?.dispose();
    super.dispose();
  }

  List<MapMarker> _filteredMarkers() {
    if (_selectedCategory == 'Todos') return _markers;
    return _markers.where((m) => m.category == _selectedCategory).toList();
  }

  void _runCameraAnimation(LatLng endCenter, double endZoom) {
    if (!mounted) return;
    final cam = _mapController.camera;
    _cameraAnim?.dispose();
    _cameraAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
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

  void _fitCameraToMarkers(String category) {
    final list = category == 'Todos'
        ? _markers
        : _markers.where((m) => m.category == category).toList();
    final points = list.map((m) => m.position).toList();
    if (points.isEmpty) {
      _runCameraAnimation(_quetameCenter, _defaultZoom);
      return;
    }
    if (points.length == 1) {
      _runCameraAnimation(points.first, 15.2);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    final cam = _mapController.camera;
    final target = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.fromLTRB(48, 120, 48, 160),
    ).fit(cam);
    _runCameraAnimation(target.center, target.zoom);
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitCameraToMarkers(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _quetameCenter,
              initialZoom: _defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quetame_turismo.app',
              ),
              MarkerLayer(
                markers: _filteredMarkers()
                    .map(
                      (marker) => Marker(
                        width: 36,
                        height: 36,
                        point: marker.position,
                        child: _MapPin(color: marker.color),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: MapHeader(
              isDarkMode: isDarkMode,
              onToggleTheme: () => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 100,
            child: CategoriesLegendCard(
              isDarkMode: isDarkMode,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Rutas',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Eventos',
          ),
        ],
      ),
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
