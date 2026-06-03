import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/core/content/firestore_fields.dart';
import 'package:quetame_turismo/models/trail_route.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

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
  List<LatLng> _activePlaceRoute = const <LatLng>[];

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
    if (_activePlaceRoute.isNotEmpty) {
      return [_activePlaceRoute];
    }
    final selected = selectedRouteForMap;
    if (selected != null && selected.pathPoints.isNotEmpty) {
      return [selected.pathPoints];
    }
    if (_isRoutesTabActive) {
      return geoRoutes;
    }
    return const [];
  }

  void setActivePlaceRoute(List<LatLng> points) {
    _activePlaceRoute = List<LatLng>.unmodifiable(points);
    notifyListeners();
  }

  void clearActivePlaceRoute() {
    if (_activePlaceRoute.isEmpty) return;
    _activePlaceRoute = const <LatLng>[];
    notifyListeners();
  }

  bool get hasActivePlaceRoute => _activePlaceRoute.isNotEmpty;
  List<LatLng> get activePlaceRoute => List.unmodifiable(_activePlaceRoute);

  void advanceRoute(LatLng currentPosition) {
    if (_activePlaceRoute.length < 2) return;

    final distance = const Distance();
    var nearestIndex = 0;
    var nearestMeters = double.infinity;
    for (var i = 0; i < _activePlaceRoute.length; i++) {
      final d = distance.as(
        LengthUnit.Meter,
        currentPosition,
        _activePlaceRoute[i],
      );
      if (d < nearestMeters) {
        nearestMeters = d;
        nearestIndex = i;
      }
    }

    if (nearestIndex <= 0) return;

    final remaining = _activePlaceRoute.sublist(nearestIndex);
    if (remaining.isEmpty) return;

    final shouldPrependCurrent = distance.as(
          LengthUnit.Meter,
          currentPosition,
          remaining.first,
        ) >
        3;

    final advanced = <LatLng>[
      if (shouldPrependCurrent) currentPosition,
      ...remaining,
    ];
    _activePlaceRoute = List<LatLng>.unmodifiable(advanced);
    notifyListeners();
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

      final firestoreMeta = await _loadRouteMetadataFromFirestore();
      _rebuildRoutesFromGeoJson(firestoreMeta);
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

  Future<Map<String, Map<String, dynamic>>> _loadRouteMetadataFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('rutas').get();
      final meta = <String, Map<String, dynamic>>{};
      for (final doc in snapshot.docs) {
        meta[doc.id] = doc.data();
        final canonical = _canonicalRouteId(doc.id);
        if (canonical != doc.id) {
          meta[canonical] = doc.data();
        }
      }
      return meta;
    } catch (e) {
      debugPrint('No se pudo cargar rutas desde Firestore: $e');
      return const {};
    }
  }

  /// Normaliza IDs de documento Firestore a los IDs internos de la app.
  String _canonicalRouteId(String docId) {
    final normalized = docId
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized == 'r1' ||
        normalized.contains('la_torre') ||
        normalized == 'latorre') {
      return 'la_torre';
    }
    if (normalized == 'r2' ||
        normalized.contains('paramo') ||
        normalized.contains('burras')) {
      return 'paramo_burras';
    }
    return normalized;
  }

  void _rebuildRoutesFromGeoJson([
    Map<String, Map<String, dynamic>> firestoreMeta = const {},
  ]) {
    final laTorrePoints = _geoRouteById['la_torre'] ?? const <LatLng>[];
    final paramoPoints = _geoRouteById['paramo_burras'] ?? const <LatLng>[];

    _routes
      ..clear()
      ..addAll([
        _buildTrailRoute(
          id: 'la_torre',
          defaultTitle: 'La Torre',
          defaultDescription:
              'Ruta de senderismo hacia La Torre. Descripción temporal; pendiente de contenido oficial municipal.',
          defaultDuration: '1 hora aprox.',
          downloaded: true,
          difficulty: 'Moderada',
          difficultyColor: AppColors.difficultyModerateBg,
          difficultyTextColor: AppColors.difficultyModerateFg,
          pathPoints: laTorrePoints,
          data: firestoreMeta['la_torre'],
        ),
        _buildTrailRoute(
          id: 'paramo_burras',
          defaultTitle: 'Páramo de las Burras',
          defaultDescription:
              'Ruta de alta montaña hacia el Páramo de las Burras. Descripción temporal; pendiente de contenido oficial municipal.',
          defaultDuration: '2 horas (en vehículo)',
          downloaded: false,
          difficulty: 'Difícil',
          difficultyColor: AppColors.difficultyHardBg,
          difficultyTextColor: AppColors.difficultyHardFg,
          pathPoints: paramoPoints,
          data: firestoreMeta['paramo_burras'],
        ),
      ]);
  }

  TrailRoute _buildTrailRoute({
    required String id,
    required String defaultTitle,
    required String defaultDescription,
    required String defaultDuration,
    required bool downloaded,
    required String difficulty,
    required Color difficultyColor,
    required Color difficultyTextColor,
    required List<LatLng> pathPoints,
    Map<String, dynamic>? data,
  }) {
    final audioRaw = FirestoreFields.readString(data, [
      'audio_url',
      'audioUrl',
      'audioguide_url',
      'audioguideUrl',
    ]);
    final imagenRaw = FirestoreFields.readString(data, [
      'imagen_url',
      'imagenUrl',
      'imagen_presentacion_url',
      'imagenPresentacionUrl',
    ]);

    return TrailRoute(
      id: id,
      title: (data?['titulo'] ?? data?['nombre'] ?? defaultTitle).toString(),
      description:
          (data?['descripcion'] ?? data?['description'] ?? defaultDescription)
              .toString(),
      distance: (data?['distancia'] ?? data?['distance'] ?? '—').toString(),
      duration: (data?['duracion'] ?? data?['duration'] ?? defaultDuration)
          .toString(),
      stops: (data?['paradas'] ?? data?['stops'] ?? '—').toString(),
      downloaded: downloaded,
      difficulty:
          (data?['dificultad'] ?? data?['difficulty'] ?? difficulty).toString(),
      difficultyColor: difficultyColor,
      difficultyTextColor: difficultyTextColor,
      pathPoints: pathPoints,
      audioUrlRaw: audioRaw.isEmpty ? null : audioRaw,
      imagenUrlRaw: imagenRaw.isEmpty ? null : imagenRaw,
    );
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
          difficultyColor: AppColors.difficultyModerateBg,
          difficultyTextColor: AppColors.difficultyModerateFg,
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
          difficultyColor: AppColors.difficultyHardBg,
          difficultyTextColor: AppColors.difficultyHardFg,
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
