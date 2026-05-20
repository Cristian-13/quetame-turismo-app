import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  /// Actualización de coordenadas sin reconstruir el árbol del mapa completo.
  final ValueNotifier<LatLng?> positionNotifier = ValueNotifier<LatLng?>(null);

  LatLng? get currentLocation => positionNotifier.value;

  bool isLocationServiceEnabled = false;
  LocationPermission permission = LocationPermission.denied;

  StreamSubscription<Position>? _positionSubscription;
  static const _distanceFilterMeters = 8.0;

  Future<void> initialize() async {
    await refreshLocationState();
    if (!isLocationServiceEnabled) {
      notifyListeners();
      return;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      notifyListeners();
      return;
    }

    await _startPositionStream();
  }

  Future<void> refreshLocationState() async {
    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    notifyListeners();
  }

  Future<void> requestPermissionAgain() async {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await _startPositionStream();
    }
    notifyListeners();
  }

  void _updatePosition(LatLng next) {
    final previous = positionNotifier.value;
    if (previous != null) {
      final delta = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        next.latitude,
        next.longitude,
      );
      if (delta < _distanceFilterMeters) {
        return;
      }
    }
    positionNotifier.value = next;
  }

  Future<void> _startPositionStream() async {
    if (!isLocationServiceEnabled) return;

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!isLocationServiceEnabled) {
      return;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 8,
      ),
    ).listen((position) {
      _updatePosition(LatLng(position.latitude, position.longitude));
    });

    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      positionNotifier.value =
          LatLng(last.latitude, last.longitude);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    positionNotifier.dispose();
    super.dispose();
  }
}
