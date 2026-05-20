import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Capa de marcador de usuario aislada: solo esta capa se repinta al mover el GPS.
class UserLocationMarkerLayer extends StatelessWidget {
  const UserLocationMarkerLayer({
    super.key,
    required this.positionListenable,
  });

  final ValueListenable<LatLng?> positionListenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LatLng?>(
      valueListenable: positionListenable,
      builder: (context, location, _) {
        if (location == null) {
          return const SizedBox.shrink();
        }
        return MarkerLayer(
          rotate: true,
          markers: [
            Marker(
              width: 24,
              height: 24,
              point: location,
              child: const _UserLocationDot(),
            ),
          ],
        );
      },
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
