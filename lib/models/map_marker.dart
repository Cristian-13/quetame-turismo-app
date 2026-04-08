import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  final String id;
  final LatLng position;
  final String category;
  final Color color;

  const MapMarker({
    required this.id,
    required this.position,
    required this.category,
    required this.color,
  });
}
