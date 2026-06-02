import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Rutas vía [OSRM](https://project-osrm.org/) (gratuito, sin API key).
class OsrmRouteService {
  OsrmRouteService._();

  static const _base = 'https://router.project-osrm.org/route/v1/driving';
  static const Duration _requestTimeout = Duration(seconds: 9);
  static const int _maxCacheEntries = 24;
  static final Map<String, List<LatLng>> _routeCache = <String, List<LatLng>>{};

  /// Orden de coordenadas en la URL: `{lon},{lat};{lon},{lat}`.
  static Future<List<LatLng>> fetchDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final cacheKey = _buildCacheKey(origin, destination);
    final cached = _routeCache[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return List<LatLng>.unmodifiable(cached);
    }

    final lon1 = origin.longitude;
    final lat1 = origin.latitude;
    final lon2 = destination.longitude;
    final lat2 = destination.latitude;
    final uri = Uri.parse(
      '$_base/$lon1,$lat1;$lon2,$lat2?overview=full&geometries=polyline',
    );

    final response = await http
        .get(
          uri,
          headers: {'User-Agent': 'QuetameTurismo/1.0 (Flutter)'},
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw OsrmRouteException('Error de red (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String?;
    if (code != 'Ok') {
      throw OsrmRouteException(code ?? 'Sin ruta');
    }

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw OsrmRouteException('No hay rutas en la respuesta');
    }

    final geometry = routes.first['geometry'] as String?;
    if (geometry == null || geometry.isEmpty) {
      throw OsrmRouteException('Geometría vacía');
    }

    final decoded = PolylinePoints.decodePolyline(geometry);
    final points = decoded
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);
    _storeCache(cacheKey, points);
    return points;
  }

  static String _buildCacheKey(LatLng origin, LatLng destination) {
    String normalize(double value) => value.toStringAsFixed(5);
    return '${normalize(origin.latitude)},${normalize(origin.longitude)}|'
        '${normalize(destination.latitude)},${normalize(destination.longitude)}';
  }

  static void _storeCache(String key, List<LatLng> points) {
    if (points.isEmpty) return;
    if (_routeCache.length >= _maxCacheEntries) {
      _routeCache.remove(_routeCache.keys.first);
    }
    _routeCache[key] = List<LatLng>.unmodifiable(points);
  }
}

class OsrmRouteException implements Exception {
  OsrmRouteException(this.message);
  final String message;

  @override
  String toString() => message;
}
