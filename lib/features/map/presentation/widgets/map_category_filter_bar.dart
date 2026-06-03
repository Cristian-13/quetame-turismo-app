import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/floating_category_button.dart';

/// Filtro de categoría del mapa (id interno + etiqueta visible).
class MapCategoryFilter {
  final String id;
  final String label;
  final IconData icon;

  const MapCategoryFilter({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Fila horizontal de iconos circulares flotantes con glassmorphism.
class MapCategoryFilterBar extends StatelessWidget {
  final String selectedFilterId;
  final ValueChanged<String> onFilterSelected;

  const MapCategoryFilterBar({
    super.key,
    required this.selectedFilterId,
    required this.onFilterSelected,
  });

  static const List<MapCategoryFilter> filters = [
    MapCategoryFilter(
      id: MapEntityCategories.todos,
      label: 'Todos',
      icon: Icons.explore_rounded,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.cultura,
      label: 'Cultura',
      icon: Icons.museum_rounded,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.historia,
      label: 'Historia',
      icon: Icons.account_balance,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.servicios,
      label: 'Servicios',
      icon: Icons.local_hospital_rounded,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.naturaleza,
      label: 'Naturaleza',
      icon: Icons.landscape_rounded,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.gastronomia,
      label: 'Gastronomía',
      icon: Icons.restaurant,
    ),
    MapCategoryFilter(
      id: MapEntityCategories.sitios,
      label: 'Sitios',
      icon: Icons.tour_rounded,
    ),
  ];

  static bool entityMatchesFilter(MapEntity entity, String filterId) {
    if (filterId == MapEntityCategories.todos || filterId == 'Todos') {
      return true;
    }
    return entity.categoria == MapEntityCategories.normalize(filterId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return FloatingCategoryButton(
            label: filter.label,
            icon: filter.icon,
            selected: selectedFilterId == filter.id,
            onTap: () => onFilterSelected(filter.id),
          );
        },
      ),
    );
  }
}
