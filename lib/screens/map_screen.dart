import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
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

class _MapScreenState extends State<MapScreen> {
  static const LatLng _quetameCenter = LatLng(4.3316, -73.8653);
  final MapController _mapController = MapController();

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
    final locationProvider = context.watch<LocationProvider>();
    final userLocation = locationProvider.currentLocation;

    final markers = [
      ...places.map(
        (place) => Marker(
          width: 36,
          height: 36,
          point: LatLng(place.latitude, place.longitude),
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => PlaceBottomSheet(place: place),
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
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.quetame_turismo.app',
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
        Positioned(
          left: 16,
          bottom: 24,
          child: CategoriesLegendCard(isDarkMode: isDarkMode),
        ),
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: _handleMyLocationPressed,
            child: const Icon(Icons.my_location),
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
