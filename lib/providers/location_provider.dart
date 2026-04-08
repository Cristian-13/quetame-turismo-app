import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? currentLocation;
  bool isLocationServiceEnabled = false;
  LocationPermission permission = LocationPermission.denied;

  StreamSubscription<Position>? _positionSubscription;

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
    _positionSubscription = Geolocator.getPositionStream().listen((position) {
      currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
