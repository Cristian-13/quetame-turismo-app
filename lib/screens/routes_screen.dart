import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/models/trail_route.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/screens/route_navigation_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = context.watch<RouteProvider>().routes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_for_offline_outlined),
          label: const Text('Descargar offline'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2F3A40),
            side: const BorderSide(color: Color(0xFFD9DEE2)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...routes.map((route) => RouteCard(route: route)),
      ],
    );
  }
}

class RouteCard extends StatelessWidget {
  final TrailRoute route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9AA7AF), Color(0xFF6E7E88)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _StatusChip(downloaded: route.downloaded),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Chip(
                      label: Text(
                        route.difficulty,
                        style: TextStyle(
                          color: route.difficultyTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: route.difficultyColor,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Text(
                route.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Text(
                route.description,
                style: const TextStyle(
                  color: Color(0xFF6B747C),
                  fontSize: 13,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  _StatItem(icon: Icons.place_outlined, value: route.distance),
                  const SizedBox(width: 16),
                  _StatItem(icon: Icons.schedule_outlined, value: route.duration),
                  const SizedBox(width: 16),
                  _StatItem(icon: Icons.play_circle_outline, value: route.stops),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audioguia incluida',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Narracion cultural y puntos clave disponibles sin conexion.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5D666E)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RouteNavigationScreen(route: route),
                      ),
                    );
                  },
                  icon: const Icon(Icons.near_me),
                  label: const Text('Iniciar ruta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.flagGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool downloaded;

  const _StatusChip({required this.downloaded});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = downloaded ? const Color(0xFF3E8BFF) : const Color(0xFFB0B8C0);
    return Chip(
      avatar: Icon(
        downloaded ? Icons.check_circle : Icons.download_outlined,
        color: Colors.white,
        size: 16,
      ),
      label: Text(
        downloaded ? 'Descargado' : 'Sin descarga',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: bgColor,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5E6870)),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4A545D),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

