import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quetame Bicentenario',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Turismo Inteligente',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF35B8B4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
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
