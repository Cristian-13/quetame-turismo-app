import 'package:flutter/material.dart';
import 'package:quetame_turismo/core/widgets/quetame_network_image.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/screens/place_detail_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';
import 'package:quetame_turismo/theme/app_theme_extension.dart';

class PlaceBottomSheet extends StatelessWidget {
  final PlaceModel place;

  /// Trazar ruta OSRM desde la ubicación del usuario hasta [place].
  final Future<void> Function(PlaceModel place) onRutaPressed;

  const PlaceBottomSheet({
    super.key,
    required this.place,
    required this.onRutaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final extras = Theme.of(context).extension<QuetameThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: extras.elevatedSurface,
        borderRadius: AppRadii.topSheet,
        border: Border.all(color: extras.elevatedBorder, width: 1),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: AppRadii.md,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: AppRadii.lg,
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: QuetameNetworkImage(
                url: place.imagenPresentacionUrl,
                fit: BoxFit.cover,
                placeholderIcon: Icons.place_outlined,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              Chip(
                label: Text(place.category.label),
                backgroundColor: place.category.color.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: place.category.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailScreen(place: place),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.md,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Ver detalles'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => onRutaPressed(place),
                icon: const Icon(Icons.directions),
                tooltip: 'Ruta',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
