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
  final String? audioguidePath;

  /// URL de audioguía en CDN (o `null` si no hay archivo configurado).
  String? get audioguideUrl =>
      QuetameCdnUrls.resolveAudio(audioguidePath) ??
      QuetameCdnUrls.routeAudioguide(id);

  String? get coverImageUrl => QuetameCdnUrls.routeCoverImage(id);

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
    this.audioguidePath,
  });
}
