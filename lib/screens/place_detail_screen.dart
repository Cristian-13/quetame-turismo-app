import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  bool _isFavorite = false;

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final showMenu = place.rawCategory.trim().toLowerCase() == 'restaurante';
    final historia = (place.historia ?? '').trim().isEmpty
        ? 'Historia no disponible'
        : place.historia!.trim();
    final descripcion = place.description.trim().isEmpty
        ? 'Descripción no disponible'
        : place.description.trim();
    final horarios = place.horarios?.trim() ?? '';
    final pageBg = isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : colorScheme.surface;

    return Scaffold(
      backgroundColor: pageBg,
      body: DefaultTabController(
        length: showMenu ? 3 : 2,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _TopGallery(imageUrl: place.imageUrl),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _CircleActionButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _CircleActionButton(
                        icon: Icons.share_outlined,
                        onPressed: () => _showActionSnack(
                          'Compartiendo ${place.name}...',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CircleActionButton(
                        icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                        onPressed: () => setState(() => _isFavorite = !_isFavorite),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 260),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  decoration: BoxDecoration(
                    color: sheetBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.flagGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Abierto ahora',
                            style: TextStyle(
                              color: AppColors.flagGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showActionSnack(
                                'Abriendo direcciones de ${place.name}...',
                              ),
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Direcciones'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.flagGreen,
                                side: const BorderSide(
                                  color: AppColors.flagGreen,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.md,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showActionSnack(
                                'Llamando a ${place.name}...',
                              ),
                              icon: const Icon(Icons.call),
                              label: const Text('Llamar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.flagGreen,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.md,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        isScrollable: false,
                        tabAlignment: TabAlignment.fill,
                        indicatorColor: AppColors.flagGreen,
                        labelColor: AppColors.flagGreen,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        tabs: [
                          const Tab(text: 'Historia'),
                          if (showMenu) const Tab(text: 'Menú'),
                          const Tab(text: 'Horarios'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            _TextTab(content: historia),
                            if (showMenu) const _MenuTab(),
                            _ScheduleTab(horarios: horarios),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Descripción',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        descripcion,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 1040),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopGallery extends StatelessWidget {
  final String imageUrl;

  const _TopGallery({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Row(
        children: [
          Expanded(flex: 2, child: _GalleryImage(url: imageUrl)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _GalleryImage(
                    url: imageUrl,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _GalleryImage(
                    url: imageUrl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String url;

  const _GalleryImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: const Color(0xFFDDE2E6)),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: isDark
            ? const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ]
            : AppShadows.soft,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  final String content;

  const _TextTab({required this.content});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Text(
        content,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Text(
        'Consulta el menú del establecimiento directamente en el lugar.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final String horarios;

  const _ScheduleTab({required this.horarios});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: _HoursCard(horarios: horarios));
  }
}

class _HoursCard extends StatelessWidget {
  final String horarios;

  const _HoursCard({required this.horarios});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horarios',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            horarios.isEmpty ? 'Horarios no disponibles' : horarios,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
