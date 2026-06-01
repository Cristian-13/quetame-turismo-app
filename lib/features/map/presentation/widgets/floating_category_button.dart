import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_container.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Botón circular flotante premium (mapa y dashboard).
class FloatingCategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  const FloatingCategoryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.goldPrimary : null,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: selected
                ? Icon(icon, color: scheme.onPrimary, size: 30)
                : SizedBox(
                    width: size,
                    height: size,
                    child: MapGlassContainer(
                      borderRadius: BorderRadius.circular(size / 2),
                      padding: EdgeInsets.zero,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.goldPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 12,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected
                    ? AppColors.goldPrimary
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
