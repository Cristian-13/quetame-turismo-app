import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Leyenda de categorías del mapa: cada ítem es seleccionable y filtra marcadores.
class CategoriesLegendCard extends StatelessWidget {
  final bool isDarkMode;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoriesLegendCard({
    super.key,
    required this.isDarkMode,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categoryKeys = [
    'Todos',
    'Historia',
    'Naturaleza',
    'Mirador',
    'Gastronomía',
  ];

  /// Color del punto en leyenda (alineado con [PlaceCategory] y marcadores demo).
  static Color dotColorForLabel(String label) {
    switch (label) {
      case 'Historia':
        return const Color(0xFF8A4B22);
      case 'Naturaleza':
        return AppColors.flagGreen;
      case 'Mirador':
        return const Color(0xFF4D74D9);
      case 'Gastronomía':
        return const Color(0xFFF15A4A);
      default:
        return AppColors.flagGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF2B2B2B);

    return Container(
      constraints: const BoxConstraints(maxWidth: 168),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Categorías',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...categoryKeys.map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _CategoryChip(
                label: label,
                dotColor: label == 'Todos'
                    ? AppColors.primaryTerracotta
                    : dotColorForLabel(label),
                selected: selectedCategory == label,
                isDarkMode: isDarkMode,
                onTap: () => onCategorySelected(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool selected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.dotColor,
    required this.selected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mutedText = isDarkMode ? Colors.white70 : const Color(0xFF545454);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.flagGreen.withValues(alpha: isDarkMode ? 0.35 : 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.flagGreen : Colors.transparent,
              width: selected ? 1.5 : 0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.flagGreen : mutedText,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.flagGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
