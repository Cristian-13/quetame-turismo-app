import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/features/map/presentation/map_view_model.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_container.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_search_bar.dart';
class MapSearchOverlay extends StatefulWidget {
  final MapViewModel viewModel;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<MapEntity> onSuggestionSelected;
  final Widget categoryBar;

  const MapSearchOverlay({
    super.key,
    required this.viewModel,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSuggestionSelected,
    required this.categoryBar,
  });

  @override
  State<MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends State<MapSearchOverlay> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    widget.viewModel.setSearchFocused(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final showSuggestions = widget.viewModel.searchFocused;
        final suggestions = widget.viewModel.searchSuggestions;
        final showPopularLabel =
            widget.viewModel.searchQuery.isEmpty && suggestions.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapGlassSearchBar(
              controller: widget.searchController,
              focusNode: _focusNode,
              onChanged: widget.onSearchChanged,
            ),
            if (showSuggestions) ...[
              const SizedBox(height: 8),
              MapGlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showPopularLabel
                          ? 'Sugerencias populares'
                          : 'Resultados',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (suggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No hay coincidencias',
                          style: theme.textTheme.bodySmall,
                        ),
                      )
                    else
                      ...suggestions.map(
                        (entity) => _SuggestionTile(
                          entity: entity,
                          onTap: () {
                            _focusNode.unfocus();
                            widget.viewModel.setSearchFocused(false);
                            widget.onSuggestionSelected(entity);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            widget.categoryBar,
          ],
        );
      },
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final MapEntity entity;
  final VoidCallback onTap;

  const _SuggestionTile({required this.entity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.place_rounded,
                size: 20,
                color: entity.badgeColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${entity.typeBadgeLabel} · ${entity.categoryLabel}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
