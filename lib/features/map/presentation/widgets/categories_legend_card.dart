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
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.black12;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categoryKeys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = categoryKeys[index];
          return _CategoryChip(
            label: label,
            selected: selectedCategory == label,
            isDarkMode: isDarkMode,
            onTap: () => onCategorySelected(label),
          );
        },
      ),
    );
  }
}

class _CategoryData {
  final String label;
  final IconData icon;

  const _CategoryData({required this.label, required this.icon});
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.isDarkMode,
    required this.onTap,
  });

  static const List<_CategoryData> _categories = [
    _CategoryData(label: 'Todos', icon: Icons.grid_view_rounded),
    _CategoryData(label: 'Historia', icon: Icons.account_balance),
    _CategoryData(label: 'Naturaleza', icon: Icons.terrain),
    _CategoryData(label: 'Mirador', icon: Icons.visibility),
    _CategoryData(label: 'Gastronomía', icon: Icons.restaurant),
  ];

  IconData _iconForLabel(String currentLabel) {
    for (final category in _categories) {
      if (category.label == currentLabel) return category.icon;
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedBackground = AppColors.flagGreen;
    final Color unselectedBackground = isDarkMode
        ? const Color(0xFF2A2F33)
        : Colors.white;
    final Color unselectedBorder = isDarkMode
        ? const Color(0xFF46505A)
        : const Color(0xFFD6DDE3);
    final Color unselectedForeground = isDarkMode
        ? const Color(0xFFE8EDF2)
        : const Color(0xFF37424A);
    final icon = _iconForLabel(label);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? selectedBackground : unselectedBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? selectedBackground : unselectedBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : unselectedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : unselectedForeground,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
