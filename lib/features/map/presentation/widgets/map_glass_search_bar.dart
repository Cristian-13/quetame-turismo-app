import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_container.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Barra de búsqueda flotante con efecto cristal sobre el mapa.
class MapGlassSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const MapGlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<MapGlassSearchBar> createState() => _MapGlassSearchBarState();
}

class _MapGlassSearchBarState extends State<MapGlassSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(MapGlassSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _clear() {
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasText = widget.controller.text.isNotEmpty;

    return MapGlassContainer(
      borderRadius: BorderRadius.circular(30),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.goldPrimary,
        decoration: InputDecoration(
          hintText: 'Buscar en Quetame...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.goldPrimary,
            size: 24,
          ),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: _clear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 22,
                  ),
                  tooltip: 'Limpiar búsqueda',
                )
              : null,
        ),
      ),
    );
  }
}
