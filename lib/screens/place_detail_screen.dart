import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final showMenu = place.category == PlaceCategory.gastronomia;

    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
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
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      _CircleActionButton(
                        icon: Icons.favorite_border,
                        onPressed: () {},
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.topSheet,
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
                              onPressed: () {},
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
                              onPressed: () {},
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
                        isScrollable: true,
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
                            _HistoryTab(description: place.description),
                            if (showMenu) const _MenuTab(),
                            const _ScheduleTab(),
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
              children: const [
                Expanded(
                  child: _GalleryImage(
                    url:
                        'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=800&q=60',
                  ),
                ),
                SizedBox(height: 4),
                Expanded(
                  child: _GalleryImage(
                    url:
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=60',
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xFF39434C)),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final String description;

  const _HistoryTab({required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Text(
        description,
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
    return const SingleChildScrollView(
      child: Column(
        children: [
          _MenuItemCard(
            title: 'Chicharrón Crujiente',
            price: '\$25,000 COP',
            description:
                'Porción tradicional con arepa, papa criolla y ají casero.',
          ),
          _MenuItemCard(
            title: 'Ajiaco Cundinamarqués',
            price: '\$22,000 COP',
            description:
                'Sopa espesa con pollo, papa y guasca, ideal para clima frío.',
          ),
          _MenuItemCard(
            title: 'Chocolate Campesino',
            price: '\$9,000 COP',
            description:
                'Bebida caliente con queso y almojábana recién horneada.',
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(child: _HoursCard());
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard();

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
            'Lunes - Viernes: 8:00 AM - 6:00 PM',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            'Sábado: 9:00 AM - 7:00 PM',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            'Domingo: 9:00 AM - 5:00 PM',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;

  const _MenuItemCard({
    required this.title,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.md,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.md,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(
                'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=500&q=60',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFFDDE2E6)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryTerracotta,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
