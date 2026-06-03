import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

enum MapEntityType { turismo }

/// Entidad unificada del mapa (solo origen Firestore).
class MapEntity {
  final String id;
  final String nombre;
  final String description;
  final String categoria;
  final MapEntityType type;
  final double latitud;
  final double longitud;
  final String? displayImageUrl;
  final FirestoreMapSite _firestoreSource;

  MapEntity({
    required this.id,
    required this.nombre,
    required this.description,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    required this.displayImageUrl,
    required FirestoreMapSite firestoreSource,
    this.type = MapEntityType.turismo,
  });

  String get name => nombre;
  String get categoryLabel => categoria;
  double get latitude => latitud;
  double get longitude => longitud;

  LatLng get latLng => LatLng(latitud, longitud);

  bool get hasPlaceDetail => type == MapEntityType.turismo;

  bool get hasImage =>
      displayImageUrl != null && displayImageUrl!.trim().isNotEmpty;

  Color get badgeColor => switch (type) {
        MapEntityType.turismo => AppColors.goldPrimary,
      };

  String get typeBadgeLabel => switch (type) {
        MapEntityType.turismo => 'Turismo',
      };

  factory MapEntity.fromFirestore(FirestoreMapSite site) {
    return MapEntity(
      id: site.id,
      nombre: site.nombre,
      descripcion: site.descripcion,
      categoria: site.category,
      type: MapEntityType.turismo,
      latitud: site.latitud,
      longitud: site.longitud,
      displayImageUrl: site.displayImageUrl,
      firestoreSource: site,
    );
  }

  PlaceModel toPlaceModel() => _firestoreSource.toPlaceModel();
}
