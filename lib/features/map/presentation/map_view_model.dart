import 'package:flutter/foundation.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_category_filter_bar.dart';

/// Estado único del mapa: filtra [allEntities] (turismo + comercio).
class MapViewModel extends ChangeNotifier {
  List<MapEntity> _allEntities = const [];
  String _selectedFilterId = MapEntityCategories.todos;
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
  bool _derivedDirty = true;
  List<MapEntity> _filteredCache = const [];
  List<MapEntity> _suggestionsCache = const [];

  void setEntities(List<MapEntity> entities) {
    final signature = entities
        .map(
          (e) =>
              '${e.id}|${e.name}|${e.categoryLabel}|${e.latitude.toStringAsFixed(5)}|${e.longitude.toStringAsFixed(5)}',
        )
        .join('||');
    if (_entitiesSignature == signature) return;
    _entitiesSignature = signature;
    _allEntities = entities;
    _markDerivedDirty();
    notifyListeners();
  }

  void setFilter(String filterId) {
    if (_selectedFilterId == filterId) return;
    _selectedFilterId = filterId;
    clearSelection();
    _markDerivedDirty();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    final next = query.trim();
    if (_searchQuery == next) return;
    _searchQuery = next;
    _markDerivedDirty();
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
    _ensureDerivedComputed();
    return _filteredCache;
  }

  List<MapEntity> get searchSuggestions {
    _ensureDerivedComputed();
    return _suggestionsCache;
  }

  void _ensureDerivedComputed() {
    if (!_derivedDirty) return;

    final byCategory = _allEntities.where(
      (entity) => MapCategoryFilterBar.entityMatchesFilter(
        entity,
        _selectedFilterId,
      ),
    );
    final byCategoryList = byCategory.toList(growable: false);

    if (_searchQuery.isEmpty) {
      _filteredCache = byCategoryList;
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredCache = byCategoryList
          .where((entity) => entity.name.toLowerCase().contains(q))
          .toList(growable: false);
    }

    if (_searchQuery.isEmpty) {
      _suggestionsCache = _resolvePopularEntities();
    } else {
      final q = _searchQuery.toLowerCase();
      _suggestionsCache = _allEntities
        .where((entity) => entity.name.toLowerCase().contains(q))
        .toList();
    }
    if (_suggestionsCache.length > 8) {
      _suggestionsCache = _suggestionsCache.take(8).toList(growable: false);
    } else {
      _suggestionsCache = List.unmodifiable(_suggestionsCache);
    }

    _derivedDirty = false;
  }

  void _markDerivedDirty() {
    _derivedDirty = true;
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
