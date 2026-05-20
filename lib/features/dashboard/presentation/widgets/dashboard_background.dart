import 'package:flutter/material.dart';

/// Fondo decorativo del dashboard con overlay para legibilidad.
class DashboardBackground extends StatelessWidget {
  const DashboardBackground({super.key});

  static const String assetPath = 'assets/images/quetame_bg.jpg';
  static const String fallbackNetworkUrl =
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1600&q=80';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayTop = isDark ? 0.55 : 0.42;
    final overlayBottom = isDark ? 0.65 : 0.52;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Image.network(
            fallbackNetworkUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: overlayTop),
                Colors.black.withValues(alpha: overlayBottom),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
