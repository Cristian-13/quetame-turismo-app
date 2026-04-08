import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TrailRoute {
  final String id;
  final String title;
  final String description;
  final String distance;
  final String duration;
  final String stops;
  final bool downloaded;
  final String difficulty;
  final Color difficultyColor;
  final Color difficultyTextColor;
  final List<LatLng> pathPoints;

  /// URL de prueba de audioguía por ruta (SoundHelix 1 → r1, SoundHelix 2 → r2).
  String get audioguideUrl {
    switch (id) {
      case 'r1':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      case 'r2':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
      default:
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    }
  }

  const TrailRoute({
    required this.id,
    required this.title,
    required this.description,
    required this.distance,
    required this.duration,
    required this.stops,
    required this.downloaded,
    required this.difficulty,
    required this.difficultyColor,
    required this.difficultyTextColor,
    required this.pathPoints,
  });
}
