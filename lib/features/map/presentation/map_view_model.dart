import 'package:flutter/foundation.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_category_filter_bar.dart';

/// Estado único del mapa: filtra [allEntities] (turismo + comercio).
class MapViewModel extends ChangeNotifier {
  List<MapEntity> _allEntities = const [];
  String _selectedFilterId = 'Todos';
  String _searchQuery = '';
  bool _searchFocused = false;
  String? _selectedEntityId;
  MapEntity? _selectedEntity;

  static const List<String> popularSuggestionTitles = [
    'Páramo de las Burras',
    'La Torre',
    'Iglesia Principal',
    'Glamping',
    'Pan de Sagú',
  ];

  List<MapEntity> get allEntities => _allEntities;
  String get selectedFilterId => _selectedFilterId;
  String get searchQuery => _searchQuery;
  bool get searchFocused => _searchFocused;
  String? get selectedEntityId => _selectedEntityId;
  MapEntity? get selectedEntity => _selectedEntity;

  String _entitiesSignature = '';

  void setEntities(List<MapEntity> entities) {
    final signature = entities.map((e) => e.id).join('|');
    if (_entitiesSignature == signature) return;
    _entitiesSignature = signature;
    _allEntities = entities;
    notifyListeners();
  }

  void setFilter(String filterId) {
    if (_selectedFilterId == filterId) return;
    _selectedFilterId = filterId;
    clearSelection();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    final next = query.trim();
    if (_searchQuery == next) return;
    _searchQuery = next;
    notifyListeners();
  }

  void setSearchFocused(bool focused) {
    if (_searchFocused == focused) return;
    _searchFocused = focused;
    notifyListeners();
  }

  void selectEntity(MapEntity entity) {
    _selectedEntityId = entity.id;
    _selectedEntity = entity;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedEntityId == null && _selectedEntity == null) return;
    _selectedEntityId = null;
    _selectedEntity = null;
    notifyListeners();
  }

  List<MapEntity> get filteredEntities {
    final byCategory = _allEntities.where(
      (entity) => MapCategoryFilterBar.entityMatchesFilter(
        entity,
        _selectedFilterId,
      ),
    );
    if (_searchQuery.isEmpty) return byCategory.toList();

    final q = _searchQuery.toLowerCase();
    return byCategory
        .where((entity) => entity.name.toLowerCase().contains(q))
        .toList();
  }

  List<MapEntity> get searchSuggestions {
    if (_searchQuery.isEmpty) {
      return _resolvePopularEntities();
    }
    final q = _searchQuery.toLowerCase();
    return _allEntities
        .where((entity) => entity.name.toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  List<MapEntity> _resolvePopularEntities() {
    final resolved = <MapEntity>[];
    for (final title in popularSuggestionTitles) {
      final match = findEntityByName(title);
      if (match != null && !resolved.any((e) => e.id == match.id)) {
        resolved.add(match);
      }
    }
    if (resolved.isNotEmpty) return resolved;
    return _allEntities.take(4).toList();
  }

  MapEntity? findEntityByName(String name) {
    final q = name.toLowerCase();
    for (final entity in _allEntities) {
      if (entity.name.toLowerCase().contains(q)) return entity;
    }
    return null;
  }
}
