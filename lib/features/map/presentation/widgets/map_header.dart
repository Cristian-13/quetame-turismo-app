import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/dev/seed_places.dart';
import 'package:quetame_turismo/providers/place_provider.dart';
import 'package:quetame_turismo/providers/network_provider.dart';

class MapHeader extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MapHeader({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : AppColors.primaryTerracotta;
    final isConnected = context.watch<NetworkProvider>().isConnected;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, top: 14, bottom: 10),
      decoration: BoxDecoration(
        color: headerColor,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Iniciando subida de datos...'),
                        ),
                      );
                      try {
                        await seedPlacesToFirestoreFromAsset();
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('¡Datos subidos a Firebase!'),
                          ),
                        );
                        await context.read<PlaceProvider>().loadPlaces();
                      } catch (e) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text(
                      'Quetame Bicentenario',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  const Text(
                    'Turismo Inteligente',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected ? const Color(0xFF35B8B4) : const Color(0xFFB0B8C0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'Online' : 'Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggleTheme,
              style: IconButton.styleFrom(backgroundColor: Colors.white24),
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
              tooltip: 'Alternar modo nocturno',
            ),
          ],
        ),
      ),
    );
  }
}
