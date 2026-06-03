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

  /// Audioguía resuelta desde `audios_rutas/{id}` (ID exacto del documento).
  String? get audioguideUrl => QuetameCdnUrls.resolveAudio(audioUrlRaw);

  /// Alias explícito para widgets que esperan `audioUrl`.
  String? get audioUrl => audioguideUrl;

  String? get coverImageUrl {
    final fromFirestore = QuetameCdnUrls.resolveImage(imagenUrlRaw);
    if (fromFirestore != null && fromFirestore.isNotEmpty) {
      return fromFirestore;
    }
    return QuetameCdnUrls.routeCoverImage(id);
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
    this.audioUrlRaw,
    this.imagenUrlRaw,
  });
}
