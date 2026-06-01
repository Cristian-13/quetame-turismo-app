import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/presentation/map_camera_animator.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';

enum MapCameraFollowMode { fixed, tracking }

/// Control de seguimiento GPS, brújula y re-centrado del mapa.
class MapNavigationController extends ChangeNotifier {
  MapNavigationController({
    required MapController mapController,
    required MapCameraAnimator cameraAnimator,
    required LocationProvider locationProvider,
    required RouteProvider routeProvider,
  })  : _mapController = mapController,
        _cameraAnimator = cameraAnimator,
        _locationProvider = locationProvider,
        _routeProvider = routeProvider {
    _locationProvider.gpsSnapshotNotifier.addListener(_onGpsUpdate);
  }

  final MapController _mapController;
  final MapCameraAnimator _cameraAnimator;
  final LocationProvider _locationProvider;
  final RouteProvider _routeProvider;
  final ValueNotifier<double?> markerHeadingNotifier = ValueNotifier<double?>(null);

  MapCameraFollowMode followMode = MapCameraFollowMode.fixed;
  bool compassMode = false;
  bool needsRecenter = false;
  MapEntity? navigationDestination;

  double _compassHeading = 0;
  bool _hasCompassHeading = false;
  double? _lastAppliedCompassHeading;
  DateTime? _lastCompassUpdateAt;
  DateTime? _lastRouteAdvanceAt;
  DateTime? _lastCameraUpdateAt;
  LatLng? _lastCameraTarget;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _programmaticMove = false;

  static const double _followZoom = 16.2;
  static const double _compassAngleThresholdDeg = 1.5;
  static const Duration _compassThrottle = Duration(milliseconds: 250);
  static const Duration _routeAdvanceThrottle = Duration(seconds: 2);
  static const Duration _cameraFollowThrottle = Duration(milliseconds: 450);
  static const double _cameraMinMoveMeters = 1.8;

  double? get distanceToDestinationKm {
    final dest = navigationDestination;
    final user = _locationProvider.gpsSnapshotNotifier.value?.position;
    if (dest == null || user == null) return null;
    final meters = const Distance().as(
      LengthUnit.Meter,
      user,
      dest.latLng,
    );
    return meters / 1000;
  }

  @override
  void dispose() {
    _stopCompass();
    _locationProvider.gpsSnapshotNotifier.removeListener(_onGpsUpdate);
    markerHeadingNotifier.dispose();
    super.dispose();
  }

  void setNavigationDestination(MapEntity? entity) {
    navigationDestination = entity;
    notifyListeners();
  }

  void toggleFollowMode() {
    followMode = followMode == MapCameraFollowMode.fixed
        ? MapCameraFollowMode.tracking
        : MapCameraFollowMode.fixed;
    needsRecenter = false;
    if (followMode == MapCameraFollowMode.tracking) {
      _centerOnUser(animated: true);
    } else {
      _stopCompass();
      compassMode = false;
      _resetRotation();
    }
    notifyListeners();
  }

  Future<void> toggleCompassMode() async {
    if (compassMode) {
      compassMode = false;
      _stopCompass();
      _resetRotation(animated: true);
      final gpsHeading = _locationProvider.gpsSnapshotNotifier.value?.headingDegrees;
      markerHeadingNotifier.value = resolveMarkerHeading(
        gpsHeadingDegrees: gpsHeading,
      );
      notifyListeners();
      return;
    }

    if (FlutterCompass.events == null) {
      notifyListeners();
      return;
    }

    compassMode = true;
    await _startCompass();
    final gpsHeading = _locationProvider.gpsSnapshotNotifier.value?.headingDegrees;
    markerHeadingNotifier.value = resolveMarkerHeading(
      gpsHeadingDegrees: gpsHeading,
    );
    notifyListeners();
  }

  void onUserMapGesture() {
    if (_programmaticMove) return;
    if (followMode == MapCameraFollowMode.tracking) {
      needsRecenter = true;
      notifyListeners();
    }
  }

  void recenterOnUser() {
    needsRecenter = false;
    followMode = MapCameraFollowMode.tracking;
    _centerOnUser(animated: true);
    notifyListeners();
  }

  void _onGpsUpdate() {
    final snapshot = _locationProvider.gpsSnapshotNotifier.value;
    if (snapshot == null) return;

    markerHeadingNotifier.value = resolveMarkerHeading(
      gpsHeadingDegrees: snapshot.headingDegrees,
    );
    _maybeAdvanceActiveRoute(snapshot.position);

    if (followMode != MapCameraFollowMode.tracking) {
      return;
    }
    if (needsRecenter) {
      return;
    }
    if (!_shouldUpdateFollowCamera(snapshot.position)) {
      return;
    }

    _programmaticMove = true;
    _lastCameraUpdateAt = DateTime.now();
    _lastCameraTarget = snapshot.position;
    _cameraAnimator.animatedMapMove(
      target: snapshot.position,
      zoom: _followZoom,
      duration: const Duration(milliseconds: 400),
      onComplete: () => _programmaticMove = false,
    );
  }

  void _centerOnUser({required bool animated}) {
    final snap = _locationProvider.gpsSnapshotNotifier.value;
    if (snap == null) return;

    _programmaticMove = true;
    if (animated) {
      _cameraAnimator.animatedMapMove(
        target: snap.position,
        zoom: _followZoom,
        onComplete: () => _programmaticMove = false,
      );
    } else {
      _mapController.move(snap.position, _followZoom);
      _programmaticMove = false;
    }
  }

  Future<void> _startCompass() async {
    final events = FlutterCompass.events;
    if (events == null) return;

    await _compassSubscription?.cancel();
    _lastAppliedCompassHeading = null;
    _lastCompassUpdateAt = null;

    var firstEvent = true;
    _compassSubscription = events.listen((event) {
      final heading = event.heading;
      if (heading == null || !compassMode) return;
      _applyCompassHeading(heading, force: firstEvent);
      firstEvent = false;
    });
  }

  void _applyCompassHeading(double heading, {required bool force}) {
    if (!compassMode && !force) return;

    final normalized = _normalizeHeading(heading);
    _compassHeading = normalized;
    _hasCompassHeading = true;

    if (!force) {
      final last = _lastAppliedCompassHeading;
      if (last != null &&
          _angularDifference(normalized, last) < _compassAngleThresholdDeg) {
        return;
      }

      final now = DateTime.now();
      if (_lastCompassUpdateAt != null &&
          now.difference(_lastCompassUpdateAt!) < _compassThrottle) {
        return;
      }
      _lastCompassUpdateAt = now;
    }

    _lastAppliedCompassHeading = normalized;
    markerHeadingNotifier.value = resolveMarkerHeading(
      gpsHeadingDegrees: _locationProvider.gpsSnapshotNotifier.value?.headingDegrees,
    );
  }

  void _stopCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _lastAppliedCompassHeading = null;
    _lastCompassUpdateAt = null;
    _hasCompassHeading = false;
  }

  void _resetRotation({bool animated = false}) {
    _lastAppliedCompassHeading = null;
    _compassHeading = 0;
    _hasCompassHeading = false;
  }

  double? resolveMarkerHeading({double? gpsHeadingDegrees}) {
    if (compassMode && _hasCompassHeading) return _compassHeading;
    if (gpsHeadingDegrees != null && gpsHeadingDegrees >= 0) {
      return _normalizeHeading(gpsHeadingDegrees);
    }
    if (_hasCompassHeading) return _compassHeading;
    return null;
  }

  void _maybeAdvanceActiveRoute(LatLng currentPosition) {
    if (!_routeProvider.hasActivePlaceRoute) return;

    final now = DateTime.now();
    if (_lastRouteAdvanceAt != null &&
        now.difference(_lastRouteAdvanceAt!) < _routeAdvanceThrottle) {
      return;
    }
    _lastRouteAdvanceAt = now;
    _routeProvider.advanceRoute(currentPosition);
  }

  bool _shouldUpdateFollowCamera(LatLng nextPosition) {
    final now = DateTime.now();
    if (_lastCameraUpdateAt != null &&
        now.difference(_lastCameraUpdateAt!) < _cameraFollowThrottle) {
      return false;
    }

    final last = _lastCameraTarget;
    if (last == null) return true;

    final moved = const Distance().as(
      LengthUnit.Meter,
      last,
      nextPosition,
    );
    return moved >= _cameraMinMoveMeters;
  }

  static double _normalizeHeading(double degrees) {
    var h = degrees % 360;
    if (h < 0) h += 360;
    return h;
  }

  static double _angularDifference(double a, double b) {
    var diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  String formatDistanceKm(double? km) {
    if (km == null) return '—';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }

  String formatSpeedKmh(double speedKmh) {
    if (speedKmh < 0) return '—';
    return '${speedKmh.toStringAsFixed(0)} km/h';
  }
}
