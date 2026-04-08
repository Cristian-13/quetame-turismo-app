import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/models/trail_route.dart';

class RouteProvider extends ChangeNotifier {
  final List<TrailRoute> _routes = const [
    TrailRoute(
      id: 'r1',
      title: 'Cascadas y Naturaleza',
      description: 'Sendero escenico entre cascadas, bosque andino y fauna local.',
      distance: '7.2 km',
      duration: '4h',
      stops: '2 paradas',
      downloaded: true,
      difficulty: 'Moderada',
      difficultyColor: Color(0xFFFFE08A),
      difficultyTextColor: Color(0xFF6C4D00),
      pathPoints: [
        LatLng(4.3316, -73.8653),
        LatLng(4.3323, -73.8650),
        LatLng(4.3331, -73.8648),
        LatLng(4.3340, -73.8646),
        LatLng(4.3348, -73.8644),
      ],
    ),
    TrailRoute(
      id: 'r2',
      title: 'Miradores del Valle',
      description: 'Ruta panoramica con vistas al valle y puntos fotograficos.',
      distance: '5.8 km',
      duration: '3h',
      stops: '3 paradas',
      downloaded: false,
      difficulty: 'Dificil',
      difficultyColor: Color(0xFFFFB4A8),
      difficultyTextColor: Color(0xFF8E1D15),
      pathPoints: [
        LatLng(4.3316, -73.8653),
        LatLng(4.3309, -73.8656),
        LatLng(4.3301, -73.8659),
        LatLng(4.3294, -73.8662),
        LatLng(4.3288, -73.8665),
      ],
    ),
  ];

  List<TrailRoute> get routes => List.unmodifiable(_routes);
}
