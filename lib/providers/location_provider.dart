import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Telemetría GPS en tiempo real para navegación en mapa.
class UserGpsSnapshot {
  final LatLng position;
  final double speedKmh;
  final double? headingDegrees;
  final double accuracyMeters;

  const UserGpsSnapshot({
    required this.position,
    required this.speedKmh,
    required this.headingDegrees,
    required this.accuracyMeters,
  });
}

class LocationProvider extends ChangeNotifier {
  final ValueNotifier<LatLng?> positionNotifier = ValueNotifier<LatLng?>(null);
  final ValueNotifier<UserGpsSnapshot?> gpsSnapshotNotifier =
      ValueNotifier<UserGpsSnapshot?>(null);

  LatLng? get currentLocation => positionNotifier.value;

  bool isLocationServiceEnabled = false;
  LocationPermission permission = LocationPermission.denied;

  StreamSubscription<Position>? _positionSubscription;
  static const _distanceFilterMeters = 2.0;

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

  void _applyPosition(Position position) {
    final next = LatLng(position.latitude, position.longitude);
    final previous = positionNotifier.value;

    final speedKmh = position.speed >= 0 ? position.speed * 3.6 : 0.0;
    final heading = position.heading >= 0 ? position.heading : null;

    gpsSnapshotNotifier.value = UserGpsSnapshot(
      position: next,
      speedKmh: speedKmh,
      headingDegrees: heading,
      accuracyMeters: position.accuracy,
    );

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

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    await _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen(_applyPosition);

    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      _applyPosition(last);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    positionNotifier.dispose();
    gpsSnapshotNotifier.dispose();
    super.dispose();
  }
}
