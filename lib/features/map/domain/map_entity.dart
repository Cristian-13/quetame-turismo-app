import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_type.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Entidad unificada del mapa (solo origen Firestore).
class MapEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final MapEntityType type;
  final double latitud;
  final double longitud;
  final String? imagenPresentacionUrl;
  final String? imagenMenuUrl;
  final String historia;
  final String horarios;
  final String? horaApertura;
  final String? horaCierre;
  final FirestoreMapSite _firestoreSource;

  MapEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.type,
    required this.latitud,
    required this.longitud,
    required this.imagenPresentacionUrl,
    required this.imagenMenuUrl,
    required this.historia,
    required this.horarios,
    this.horaApertura,
    this.horaCierre,
    required FirestoreMapSite firestoreSource,
  }) : _firestoreSource = firestoreSource;

  String get name => nombre;
  String get description => descripcion;
  String get categoryLabel => MapEntityCategories.displayLabel(categoria);
  double get latitude => latitud;
  double get longitude => longitud;

  /// Alias de compatibilidad con widgets anteriores.
  String? get displayImageUrl => imagenPresentacionUrl;

  LatLng get latLng => LatLng(latitud, longitud);

  bool get hasPlaceDetail => true;

  bool get isRestaurante => type == MapEntityType.restaurante;

  bool get hasImage =>
      imagenPresentacionUrl != null &&
      imagenPresentacionUrl!.trim().isNotEmpty;

  bool get hasMenu =>
      isRestaurante &&
      imagenMenuUrl != null &&
      imagenMenuUrl!.trim().isNotEmpty;

  Color get badgeColor => switch (type) {
        MapEntityType.restaurante || MapEntityType.gastronomia =>
          AppColors.categoryGastronomia,
        MapEntityType.sendero || MapEntityType.naturaleza =>
          AppColors.categoryNaturaleza,
        MapEntityType.historia => AppColors.categoryHistoria,
        MapEntityType.cultura => AppColors.goldMuted,
        MapEntityType.servicios => const Color(0xFF0EA5A8),
        MapEntityType.sitio => AppColors.goldPrimary,
      };

  String get typeBadgeLabel => switch (type) {
        MapEntityType.restaurante => 'Restaurante',
        MapEntityType.sendero => 'Sendero',
        MapEntityType.sitio => 'Sitio',
        MapEntityType.cultura => 'Cultura',
        MapEntityType.historia => 'Historia',
        MapEntityType.servicios => 'Servicios',
        MapEntityType.naturaleza => 'Naturaleza',
        MapEntityType.gastronomia => 'Gastronomía',
      };

  factory MapEntity.fromFirestore(FirestoreMapSite site) {
    return MapEntity(
      id: site.id,
      nombre: site.nombre,
      descripcion: site.descripcion,
      categoria: site.categoria,
      type: parseEntityType(site.tipo),
      latitud: site.latitud,
      longitud: site.longitud,
      imagenPresentacionUrl: site.imagenPresentacionUrl,
      imagenMenuUrl: site.imagenMenuUrl,
      historia: site.historia,
      horarios: site.horarios,
      horaApertura:
          site.horaApertura.trim().isEmpty ? null : site.horaApertura.trim(),
      horaCierre: site.horaCierre.trim().isEmpty ? null : site.horaCierre.trim(),
      firestoreSource: site,
    );
  }

  PlaceModel toPlaceModel() => _firestoreSource.toPlaceModel();
}
