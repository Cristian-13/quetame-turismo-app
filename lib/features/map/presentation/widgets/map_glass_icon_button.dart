import 'package:flutter/material.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_container.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Botón flotante circular con efecto cristal sobre el mapa.
class MapGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool compact;

  const MapGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 52.0;

    final button = MapGlassContainer(
      borderRadius: BorderRadius.circular(size / 2),
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.goldDeep),
          tooltip: tooltip,
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
