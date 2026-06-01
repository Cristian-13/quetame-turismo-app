import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

enum MapEntityType { turismo }

/// Entidad unificada del mapa para puntos turísticos y ecológicos.
class MapEntity {
  final String id;
  final String nombre;
  final String description;
  final String categoria;
  final MapEntityType type;
  final double latitud;
  final double longitud;
  final String imagenUrl;
  final FirestoreMapSite? _firestoreSource;

  MapEntity({
    required this.id,
    String? name,
    String? nombre,
    String? description,
    String? descripcion,
    String? categoryLabel,
    String? categoria,
    this.type = MapEntityType.turismo,
    double? latitude,
    double? latitud,
    double? longitude,
    double? longitud,
    String? imageUrl,
    String? imagenUrl,
    FirestoreMapSite? firestoreSource,
  })  : nombre = nombre ?? name ?? '',
        description = descripcion ?? description ?? '',
        categoria = categoria ?? categoryLabel ?? 'Naturaleza',
        latitud = latitud ?? latitude ?? 0,
        longitud = longitud ?? longitude ?? 0,
        imagenUrl = imagenUrl ?? imageUrl ?? '',
        _firestoreSource = firestoreSource;

  String get name => nombre;
  String get categoryLabel => categoria;
  double get latitude => latitud;
  double get longitude => longitud;
  String get imageUrl => imagenUrl;

  LatLng get latLng => LatLng(latitud, longitud);

  String get displayImageUrl => imagenUrl;

  bool get hasPlaceDetail =>
      type == MapEntityType.turismo && _firestoreSource != null;

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
      imagenUrl: site.displayImageUrl,
      firestoreSource: site,
    );
  }

  PlaceModel? toPlaceModel() => _firestoreSource?.toPlaceModel();
}
