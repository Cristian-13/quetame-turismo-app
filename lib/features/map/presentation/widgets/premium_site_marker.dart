import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Marcador circular premium: borde dorado, sombra suave e icono de categoría.
class PremiumSiteMarker extends StatelessWidget {
  final String categoryLabel;
  final MapEntityType? entityType;
  final bool isSelected;
  final VoidCallback onTap;

  const PremiumSiteMarker({
    super.key,
    required this.categoryLabel,
    this.entityType,
    required this.isSelected,
    required this.onTap,
  });

  static IconData iconForCategory(String label, MapEntityType? type) {
    switch (label) {
      case 'Historia':
        return Icons.account_balance;
      case 'Cultura':
        return Icons.museum_rounded;
      case 'Servicios':
        return Icons.local_hospital_rounded;
      case 'Mirador':
        return Icons.visibility;
      case 'Gastronomía':
        return Icons.restaurant;
      case 'Naturaleza':
        return Icons.terrain;
      default:
        return Icons.place_rounded;
    }
  }

  static Color accentForCategory(String label) {
    switch (label) {
      case 'Historia':
        return AppColors.categoryHistoria;
      case 'Cultura':
        return AppColors.goldMuted;
      case 'Servicios':
        return const Color(0xFF0EA5A8);
      case 'Mirador':
        return AppColors.categoryMirador;
      case 'Gastronomía':
        return AppColors.categoryGastronomia;
      case 'Naturaleza':
      default:
        return AppColors.categoryNaturaleza;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentForCategory(categoryLabel);
    final borderColor = AppColors.goldPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: isSelected ? 14 : 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.goldPrimary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            iconForCategory(categoryLabel, entityType),
            color: accent,
            size: isSelected ? 22 : 20,
          ),
        ),
      ),
    );
  }
}
