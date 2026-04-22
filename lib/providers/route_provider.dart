import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/models/trail_route.dart';

class RouteProvider extends ChangeNotifier {
  RouteProvider() {
    loadGeoJsonRoutes();
  }

  final List<TrailRoute> _routes = <TrailRoute>[];

  List<TrailRoute> get routes => List.unmodifiable(_routes);

  bool _isLoadingGeoRoutes = false;
  String? _geoRoutesError;
  final List<List<LatLng>> _geoRoutes = [];
  final Map<String, List<LatLng>> _geoRouteById = <String, List<LatLng>>{};

  bool _isRoutesTabActive = false;
  String? _selectedRouteIdForMap;

  bool get isLoadingGeoRoutes => _isLoadingGeoRoutes;
  String? get geoRoutesError => _geoRoutesError;
  List<List<LatLng>> get geoRoutes => List.unmodifiable(_geoRoutes);

  bool get isRoutesTabActive => _isRoutesTabActive;
  TrailRoute? get selectedRouteForMap => _selectedRouteIdForMap == null
      ? null
      : _routes.cast<TrailRoute?>().firstWhere(
            (r) => r?.id == _selectedRouteIdForMap,
            orElse: () => null,
          );

  /// Polilíneas GeoJSON visibles en el mapa principal.
  /// - Por defecto: ocultas.
  /// - Se muestran si el usuario está en la pestaña de Rutas o si hay una ruta seleccionada.
  List<List<LatLng>> get visibleGeoRoutesOnMainMap {
    final selected = selectedRouteForMap;
    if (selected != null && selected.pathPoints.isNotEmpty) {
      return [selected.pathPoints];
    }
    if (_isRoutesTabActive) {
      return geoRoutes;
    }
    return const [];
  }

  void setRoutesTabActive(bool active) {
    if (_isRoutesTabActive == active) return;
    _isRoutesTabActive = active;
    notifyListeners();
  }

  void selectRouteForMap(String? routeId) {
    if (_selectedRouteIdForMap == routeId) return;
    _selectedRouteIdForMap = routeId;
    notifyListeners();
  }

  void clearSelectedRoute() {
    if (_selectedRouteIdForMap == null) return;
    _selectedRouteIdForMap = null;
    notifyListeners();
  }

  Future<void> loadGeoJsonRoutes() async {
    _isLoadingGeoRoutes = true;
    _geoRoutesError = null;
    notifyListeners();

    try {
      final filesById = <String, String>{
        'la_torre': 'assets/routes/ruta.geojson',
        'paramo_burras': 'assets/routes/rutaparamodelasburras.geojson',
      };

      final parsed = <List<LatLng>>[];
      final byId = <String, List<LatLng>>{};

      for (final entry in filesById.entries) {
        final text = await rootBundle.loadString(entry.value);
        final paths = parseGeoJsonToLatLngPaths(text).where((p) => p.isNotEmpty).toList();
        parsed.addAll(paths);

        // Para el modelo de ruta usamos el primer path no-vacío como trazo principal.
        if (paths.isNotEmpty) {
          byId[entry.key] = paths.first;
        }
      }

      _geoRoutes
        ..clear()
        ..addAll(parsed.where((p) => p.isNotEmpty));

      _geoRouteById
        ..clear()
        ..addAll(byId);

      _rebuildRoutesFromGeoJson();
    } catch (e) {
      _geoRoutesError = e.toString();
      _geoRoutes.clear();
      _geoRouteById.clear();
      _routes
        ..clear()
        ..addAll(_fallbackRoutes());
    } finally {
      _isLoadingGeoRoutes = false;
      notifyListeners();
    }
  }

  void _rebuildRoutesFromGeoJson() {
    final laTorrePoints = _geoRouteById['la_torre'] ?? const <LatLng>[];
    final paramoPoints = _geoRouteById['paramo_burras'] ?? const <LatLng>[];

    _routes
      ..clear()
      ..addAll([
        TrailRoute(
          id: 'la_torre',
          title: 'La Torre',
          description:
              'Ruta de senderismo hacia La Torre. Descripción temporal; pendiente de contenido oficial municipal.',
          distance: '—',
          duration: '1 hora aprox.',
          stops: '—',
          downloaded: true,
          difficulty: 'Moderada',
          difficultyColor: const Color(0xFFFFE08A),
          difficultyTextColor: const Color(0xFF6C4D00),
          pathPoints: laTorrePoints,
        ),
        TrailRoute(
          id: 'paramo_burras',
          title: 'Páramo de las Burras',
          description:
              'Ruta de alta montaña hacia el Páramo de las Burras. Descripción temporal; pendiente de contenido oficial municipal.',
          distance: '—',
          duration: '2 horas (en vehículo)',
          stops: '—',
          downloaded: false,
          difficulty: 'Difícil',
          difficultyColor: const Color(0xFFFFB4A8),
          difficultyTextColor: const Color(0xFF8E1D15),
          pathPoints: paramoPoints,
        ),
      ]);
  }

  List<TrailRoute> _fallbackRoutes() => const [
        TrailRoute(
          id: 'la_torre',
          title: 'La Torre',
          description: 'Ruta de senderismo hacia La Torre.',
          distance: '—',
          duration: '—',
          stops: '—',
          downloaded: false,
          difficulty: 'Moderada',
          difficultyColor: Color(0xFFFFE08A),
          difficultyTextColor: Color(0xFF6C4D00),
          pathPoints: [],
        ),
        TrailRoute(
          id: 'paramo_burras',
          title: 'Páramo de las Burras',
          description: 'Ruta de alta montaña hacia el Páramo de las Burras.',
          distance: '—',
          duration: '—',
          stops: '—',
          downloaded: false,
          difficulty: 'Difícil',
          difficultyColor: Color(0xFFFFB4A8),
          difficultyTextColor: Color(0xFF8E1D15),
          pathPoints: [],
        ),
      ];
}

/// Convierte GeoJSON (Feature, FeatureCollection, LineString o MultiLineString)
/// en una lista de paths (cada path es un `List<LatLng>`).
///
/// IMPORTANTE: GeoJSON viene como [lng, lat] → aquí se mapea a LatLng(lat, lng).
List<List<LatLng>> parseGeoJsonToLatLngPaths(String geoJsonText) {
  final decoded = jsonDecode(geoJsonText);
  final features = _extractFeatures(decoded);

  final result = <List<LatLng>>[];
  for (final feature in features) {
    final geometry = feature['geometry'];
    if (geometry is! Map) continue;

    final type = geometry['type']?.toString();
    final coordinates = geometry['coordinates'];
    if (type == 'LineString') {
      final points = _lineStringToLatLngs(coordinates);
      if (points.isNotEmpty) result.add(points);
    } else if (type == 'MultiLineString') {
      if (coordinates is List) {
        for (final line in coordinates) {
          final points = _lineStringToLatLngs(line);
          if (points.isNotEmpty) result.add(points);
        }
      }
    }
  }
  return result;
}

List<Map<String, dynamic>> _extractFeatures(Object? decoded) {
  if (decoded is Map<String, dynamic>) {
    final type = decoded['type']?.toString();
    if (type == 'Feature') {
      return [decoded];
    }
    if (type == 'FeatureCollection') {
      final features = decoded['features'];
      if (features is List) {
        return features.whereType<Map>().map(Map<String, dynamic>.from).toList();
      }
      return const [];
    }

    // A veces se guarda directamente como { geometry: ... } o similar.
    if (decoded.containsKey('geometry')) {
      return [decoded];
    }
  }
  return const [];
}

List<LatLng> _lineStringToLatLngs(Object? coordinates) {
  if (coordinates is! List) return const [];
  final points = <LatLng>[];
  for (final pair in coordinates) {
    if (pair is! List || pair.length < 2) continue;
    final lng = pair[0];
    final lat = pair[1];
    if (lng is! num || lat is! num) continue;
    points.add(LatLng(lat.toDouble(), lng.toDouble()));
  }
  return points;
}
