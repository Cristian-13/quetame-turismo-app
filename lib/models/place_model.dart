import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

enum PlaceCategory {
  historia,
  naturaleza,
  mirador,
  gastronomia,
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
        return const Color(0xFF8A4B22);
      case PlaceCategory.naturaleza:
        return AppColors.flagGreen;
      case PlaceCategory.mirador:
        return const Color(0xFF4D74D9);
      case PlaceCategory.gastronomia:
        return const Color(0xFFF15A4A);
    }
  }
}

class PlaceModel {
  final String id;
  final String name;
  final String description;
  final PlaceCategory category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? phone;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.phone,
  });
}
