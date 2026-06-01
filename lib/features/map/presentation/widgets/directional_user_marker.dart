import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Marcador direccional tipo navegación (estilo Google/Apple Maps).
class DirectionalUserMarker extends StatefulWidget {
  const DirectionalUserMarker({
    super.key,
    required this.headingDegrees,
    this.accuracyMeters = 16,
  });

  final double? headingDegrees;
  final double accuracyMeters;

  @override
  State<DirectionalUserMarker> createState() => _DirectionalUserMarkerState();
}

class _DirectionalUserMarkerState extends State<DirectionalUserMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulseSize = (widget.accuracyMeters.clamp(8, 48) * 1.6) + 12;
    final headingRadians = ((widget.headingDegrees ?? 0) * math.pi) / 180;

    return SizedBox(
      width: pulseSize,
      height: pulseSize,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: pulseSize * _pulse.value,
                height: pulseSize * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A73E8),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Transform.rotate(
                angle: headingRadians,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 22,
                    color: Color(0xFF1A73E8),
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
