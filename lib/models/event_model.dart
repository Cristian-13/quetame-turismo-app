import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

enum EventCategory {
  cultural,
  naturaleza,
}

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.naturaleza:
        return 'Naturaleza';
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.cultural:
        return AppColors.primaryTerracotta;
      case EventCategory.naturaleza:
        return AppColors.flagGreen;
    }
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String day;
  final String month;
  final String dayOfWeek;
  final String time;
  final String location;
  final String imageUrl;

  /// Inicio y fin del evento en **hora local** del dispositivo (no UTC), para [add_2_calendar].
  final DateTime startDateTime;
  final DateTime endDateTime;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.day,
    required this.month,
    required this.dayOfWeek,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.startDateTime,
    required this.endDateTime,
  });
}
