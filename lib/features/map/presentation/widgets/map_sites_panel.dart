import 'package:flutter/material.dart';
import 'package:quetame_turismo/core/widgets/quetame_network_image.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Panel inferior: lista y detalle unificados (turismo + comercio).
class MapSitesPanel extends StatelessWidget {
  final ScrollController scrollController;
  final List<MapEntity> entities;
  final MapEntity? selectedEntity;
  final ValueChanged<MapEntity> onEntitySelected;
  final VoidCallback onGoToPlace;
  final VoidCallback onViewDetails;
  final VoidCallback? onClearSelection;

  const MapSitesPanel({
    super.key,
    required this.scrollController,
    required this.entities,
    required this.selectedEntity,
    required this.onEntitySelected,
    required this.onGoToPlace,
    required this.onViewDetails,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showingDetail = selectedEntity != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          showingDetail
                              ? 'Detalle'
                              : '${entities.length} lugar${entities.length == 1 ? '' : 'es'} en la zona',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (showingDetail && onClearSelection != null)
                        TextButton(
                          onPressed: onClearSelection,
                          child: const Text('Ver lista'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (showingDetail)
            SliverToBoxAdapter(
              child: _EntityDetailCard(
                entity: selectedEntity!,
                onGoToPlace: onGoToPlace,
                onViewDetails: onViewDetails,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: entities.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entity = entities[index];
                  return _EntityListCard(
                    entity: entity,
                    onTap: () => onEntitySelected(entity),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final MapEntity entity;

  const _TypeBadge({required this.entity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: entity.badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: entity.badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        entity.typeBadgeLabel,
        style: TextStyle(
          color: entity.badgeColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EntityListCard extends StatelessWidget {
  final MapEntity entity;
  final VoidCallback onTap;

  const _EntityListCard({required this.entity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              QuetameNetworkImage(
                url: entity.imagenPresentacionUrl,
                fit: BoxFit.cover,
                placeholderIcon: Icons.landscape_outlined,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                    stops: [0.0, 0.75],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _TypeBadge(entity: entity),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      entity.categoryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntityDetailCard extends StatelessWidget {
  final MapEntity entity;
  final VoidCallback onGoToPlace;
  final VoidCallback onViewDetails;

  const _EntityDetailCard({
    required this.entity,
    required this.onGoToPlace,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  QuetameNetworkImage(
                    url: entity.imagenPresentacionUrl,
                    fit: BoxFit.cover,
                    placeholderIcon: Icons.landscape_outlined,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  entity.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _TypeBadge(entity: entity),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entity.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGoToPlace,
              icon: const Icon(Icons.near_me_rounded),
              label: const Text('Ir al lugar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (entity.hasPlaceDetail) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Ver ficha completa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.goldDeep,
                  side: const BorderSide(color: AppColors.goldPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
