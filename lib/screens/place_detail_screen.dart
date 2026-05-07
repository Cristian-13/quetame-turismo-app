import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _favoritePlacesKey = 'favorite_place_ids';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritePlacesKey) ?? <String>[];
    if (!mounted) return;
    setState(() => _isFavorite = favorites.contains(widget.place.id));
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritePlacesKey) ?? <String>[];
    if (_isFavorite) {
      favorites.remove(widget.place.id);
    } else if (!favorites.contains(widget.place.id)) {
      favorites.add(widget.place.id);
    }
    await prefs.setStringList(_favoritePlacesKey, favorites);
    if (!mounted) return;
    setState(() => _isFavorite = !_isFavorite);
  }

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sharePlace() async {
    final text =
        '¡Mira este lugar en Quetame: ${widget.place.name}! Descubre más en la app Quetame Turismo';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _callPlace() async {
    final phone = (widget.place.phone ?? '').trim();
    if (phone.isEmpty) {
      _showActionSnack('Este sitio no tiene número telefónico registrado.');
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showActionSnack('No se pudo abrir el marcador telefónico.');
    }
  }

  Future<void> _openDirections() async {
    final place = widget.place;
    final mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}',
    );
    if (!await launchUrl(mapsUri, mode: LaunchMode.externalApplication)) {
      _showActionSnack('No se pudo abrir Google Maps.');
    }
  }

  Future<void> _openMenuUrl() async {
    final menuUrl = (widget.place.menuUrl ?? '').trim();
    if (menuUrl.isEmpty) return;
    final uri = Uri.tryParse(menuUrl);
    if (uri == null) {
      _showActionSnack('El enlace del menú no es válido.');
      return;
    }
    final isImage = _isImageUrl(menuUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      _showActionSnack('No se pudo abrir el menú en el navegador.');
      return;
    }
    if (isImage) {
      _showActionSnack('Abriendo imagen del menú...');
    }
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase().split('?').first;
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  _OpenStateData _buildOpenState(PlaceModel place) {
    final apertura = _toMinutes(place.horaApertura);
    final cierre = _toMinutes(place.horaCierre);
    if (apertura == null || cierre == null) {
      return const _OpenStateData(
        label: 'Consultar horarios',
        color: Color(0xFF8A8F99),
      );
    }

    final now = DateTime.now();
    final currentMinutes = (now.hour * 60) + now.minute;
    final isOpen = apertura <= cierre
        ? currentMinutes >= apertura && currentMinutes < cierre
        : currentMinutes >= apertura || currentMinutes < cierre;

    if (isOpen) {
      return const _OpenStateData(label: 'ABIERTO', color: AppColors.flagGreen);
    }
    return const _OpenStateData(label: 'CERRADO', color: Color(0xFFD85C5C));
  }

  int? _toMinutes(String? value) {
    final raw = (value ?? '').trim();
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour * 60) + minute;
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final showMenu = place.rawCategory.trim().toLowerCase() == 'restaurante';
    final hasMenuUrl = (place.menuUrl ?? '').trim().isNotEmpty;
    final historia = (place.historia ?? '').trim().isEmpty
        ? 'Historia no disponible'
        : place.historia!.trim();
    final horarios = place.horarios?.trim() ?? '';
    final pageBg =
        isDark ? const Color(0xFF1E1E1E) : theme.scaffoldBackgroundColor;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : colorScheme.surface;
    final openState = _buildOpenState(place);

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
                        onPressed: _sharePlace,
                        iconColor: AppColors.flagGreen,
                      ),
                      const SizedBox(width: 8),
                      _CircleActionButton(
                        icon:
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                        onPressed: _toggleFavorite,
                        iconColor:
                            _isFavorite ? const Color(0xFFE24D4D) : null,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _OpenStateChip(state: openState),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _openDirections,
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
                              onPressed: _callPlace,
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
                      if (hasMenuUrl) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openMenuUrl,
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Ver Menú'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.flagGreen,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.md,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
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
  final Color? iconColor;

  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

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
        icon: Icon(icon, color: iconColor ?? theme.colorScheme.onSurface),
      ),
    );
  }
}

class _OpenStateData {
  final String label;
  final Color color;

  const _OpenStateData({required this.label, required this.color});
}

class _OpenStateChip extends StatelessWidget {
  final _OpenStateData state;

  const _OpenStateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.16),
        borderRadius: AppRadii.md,
      ),
      child: Text(
        state.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: state.color,
              fontWeight: FontWeight.w700,
            ),
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
