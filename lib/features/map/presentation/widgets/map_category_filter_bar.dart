import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
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
      id: 'Todos',
      label: 'Todos',
      icon: Icons.explore_rounded,
    ),
    MapCategoryFilter(
      id: 'Cultura',
      label: 'Cultura',
      icon: Icons.museum_rounded,
    ),
    MapCategoryFilter(
      id: 'Historia',
      label: 'Historia',
      icon: Icons.account_balance,
    ),
    MapCategoryFilter(
      id: 'Servicios',
      label: 'Servicios',
      icon: Icons.local_hospital_rounded,
    ),
    MapCategoryFilter(
      id: 'Naturaleza',
      label: 'Naturaleza',
      icon: Icons.landscape_rounded,
    ),
    MapCategoryFilter(
      id: 'Gastronomía',
      label: 'Gastronomía',
      icon: Icons.restaurant,
    ),
    MapCategoryFilter(
      id: 'sitios_turisticos',
      label: 'Sitios',
      icon: Icons.tour_rounded,
    ),
  ];

  static bool entityMatchesFilter(MapEntity entity, String filterId) {
    switch (filterId) {
      case 'Todos':
        return true;
      case 'sitios_turisticos':
        return entity.type == MapEntityType.turismo;
      default:
        return entity.categoryLabel == filterId;
    }
  }

  @Deprecated('Usar entityMatchesFilter')
  static bool siteMatchesFilter(String siteCategory, String filterId) {
    switch (filterId) {
      case 'Todos':
        return true;
      case 'sitios_turisticos':
        return const {'Historia', 'Naturaleza', 'Cultura', 'Servicios', 'Gastronomía'}
            .contains(siteCategory);
      default:
        return siteCategory == filterId;
    }
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
