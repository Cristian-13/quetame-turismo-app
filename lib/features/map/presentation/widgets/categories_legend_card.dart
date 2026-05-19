import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_theme_extension.dart';

/// Leyenda de categorías del mapa: cada ítem es seleccionable y filtra marcadores.
class CategoriesLegendCard extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoriesLegendCard({
    super.key,
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

  /// Color del punto en leyenda (alineado con [PlaceCategory] y marcadores).
  static Color dotColorForLabel(String label) =>
      PlaceCategory.pinColorForLabel(label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
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
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
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
    final scheme = Theme.of(context).colorScheme;
    final extras = Theme.of(context).extension<QuetameThemeColors>()!;
    final icon = _iconForLabel(label);

    final Color selectedBackground = scheme.primary;
    final Color unselectedBackground = extras.elevatedSurface;
    final Color unselectedBorder = extras.elevatedBorder;
    final Color unselectedForeground = scheme.onSurface;

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
            boxShadow: selected
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0DA67C00),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
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
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? Colors.white : unselectedForeground,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
