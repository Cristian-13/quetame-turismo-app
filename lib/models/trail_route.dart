import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/core/content/quetame_cdn_urls.dart';

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
  final String? audioUrlRaw;
  final String? imagenUrlRaw;

  /// Audioguía resuelta desde `audio_url` de Firestore (sin fallback cruzado).
  String? get audioguideUrl => QuetameCdnUrls.resolveAudio(audioUrlRaw);

  String? get coverImageUrl => QuetameCdnUrls.resolveImage(imagenUrlRaw);

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
    this.audioUrlRaw,
    this.imagenUrlRaw,
  });
}
