import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Transiciones suaves de cámara (evita saltos bruscos en el mapa).
class MapCameraAnimator {
  MapCameraAnimator({
    required this.mapController,
    required this.vsync,
  });

  final MapController mapController;
  final TickerProvider vsync;

  AnimationController? _controller;

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  void animatedMapMove({
    required LatLng target,
    required double zoom,
    double? rotation,
    Duration duration = const Duration(milliseconds: 400),
    VoidCallback? onComplete,
  }) {
    _controller?.dispose();

    final cam = mapController.camera;
    final startCenter = cam.center;
    final startZoom = cam.zoom;
    final startRotation = cam.rotation;

    _controller = AnimationController(vsync: vsync, duration: duration);

    void tick() {
      final t = Curves.easeInOut.transform(_controller!.value);
      final lat = startCenter.latitude +
          (target.latitude - startCenter.latitude) * t;
      final lng = startCenter.longitude +
          (target.longitude - startCenter.longitude) * t;
      final z = startZoom + (zoom - startZoom) * t;

      final point = LatLng(lat, lng);
      if (rotation != null) {
        final rot = startRotation + (rotation - startRotation) * t;
        mapController.move(point, z);
        mapController.rotate(rot);
      } else {
        mapController.move(point, z);
      }
    }

    _controller!.addListener(tick);
    _controller!.forward().whenComplete(() {
      _controller?.removeListener(tick);
      _controller?.dispose();
      _controller = null;
      onComplete?.call();
    });
  }

  void animatedRotate(double rotation, {Duration duration = const Duration(milliseconds: 400)}) {
    final cam = mapController.camera;
    animatedMapMove(
      target: cam.center,
      zoom: cam.zoom,
      rotation: rotation,
      duration: duration,
    );
  }
}
