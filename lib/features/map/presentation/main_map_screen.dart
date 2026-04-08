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

class _MainMapScreenState extends State<MainMapScreen> {
  int _selectedIndex = 0;

  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);

  static const List<MapMarker> _markers = [
    MapMarker(
      id: 'm1',
      position: LatLng(4.3330, -73.8667),
      category: 'Histórico',
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
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _quetameCenter,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quetame_turismo.app',
              ),
              MarkerLayer(
                markers: _markers
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
            child: CategoriesLegendCard(isDarkMode: isDarkMode),
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
