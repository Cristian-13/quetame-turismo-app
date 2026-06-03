import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_type.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

enum PlaceCategory {
  historia,
  naturaleza,
  mirador,
  gastronomia;

  static Color pinColorForLabel(String label) {
    final normalized = MapEntityCategories.normalize(label);
    switch (normalized) {
      case MapEntityCategories.historia:
        return PlaceCategory.historia.color;
      case MapEntityCategories.naturaleza:
        return PlaceCategory.naturaleza.color;
      case MapEntityCategories.gastronomia:
        return PlaceCategory.gastronomia.color;
      case MapEntityCategories.cultura:
        return AppColors.goldMuted;
      case MapEntityCategories.servicios:
        return const Color(0xFF0EA5A8);
      default:
        return PlaceCategory.naturaleza.color;
    }
  }
}

extension PlaceCategoryX on PlaceCategory {
  String get label {
    switch (this) {
      case PlaceCategory.historia:
        return 'Historia';
      case PlaceCategory.naturaleza:
        return 'Naturaleza';
      case PlaceCategory.mirador:
        return 'Mirador';
      case PlaceCategory.gastronomia:
        return 'Gastronomía';
    }
  }

  Color get color {
    switch (this) {
      case PlaceCategory.historia:
        return AppColors.categoryHistoria;
      case PlaceCategory.naturaleza:
        return AppColors.categoryNaturaleza;
      case PlaceCategory.mirador:
        return AppColors.categoryMirador;
      case PlaceCategory.gastronomia:
        return AppColors.categoryGastronomia;
    }
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final PlaceCategory category;
  final String rawCategory;
  final MapEntityType entityType;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? historia;
  final String? horarios;
  final String? horaApertura;
  final String? horaCierre;
  final String? menuUrl;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.entityType,
    this.rawCategory = '',
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.historia,
    this.horarios,
    this.horaApertura,
    this.horaCierre,
    this.menuUrl,
  });

  String? get imagenPresentacionUrl => imageUrl;

  String? get imagenMenuUrl => menuUrl;

  bool get isRestaurante => entityType == MapEntityType.restaurante;
}
