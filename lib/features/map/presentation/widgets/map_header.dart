import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme_extension.dart';
import 'package:quetame_turismo/dev/seed_places.dart';
import 'package:quetame_turismo/providers/place_provider.dart';
import 'package:quetame_turismo/providers/network_provider.dart';

class MapHeader extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const MapHeader({
    super.key,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<QuetameThemeColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final isConnected = context.watch<NetworkProvider>().isConnected;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, top: 14, bottom: 10),
      decoration: BoxDecoration(
        color: extras.headerBackground,
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
                    child: Text(
                      'Quetame Bicentenario',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: extras.headerForeground,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Turismo Inteligente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extras.headerForeground.withValues(alpha: 0.88),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _ConnectionBadge(isConnected: isConnected),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggleTheme,
              style: IconButton.styleFrom(backgroundColor: Colors.white24),
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: extras.headerForeground,
              ),
              tooltip: 'Alternar modo nocturno',
            ),
          ],
        ),
      ),
    );
  }
}

/// Píldora de estado de red con alto contraste sobre el header dorado.
class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.statusOnline,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Online',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.statusOnlineText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusOfflineBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.statusOfflineBg.withValues(alpha: 0.85),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: AppColors.statusOfflineText.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 5),
          Text(
            'Offline',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.statusOfflineText,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
