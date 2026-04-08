import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme.dart';

class PlaceDetailScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: DefaultTabController(
        length: 4,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _TopGallery(imageUrl: place.imageUrl),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                      Text(place.name, style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (_) => const Icon(
                              Icons.star,
                              color: AppColors.secondaryGold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '4.8 (120 Reseñas)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F5860),
                            ),
                          ),
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
                      const Row(
                        children: [
                          Icon(Icons.place_outlined, color: Color(0xFF6D747B), size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Calle Principal #4-21, Quetame, Cundinamarca',
                              style: TextStyle(
                                color: Color(0xFF6D747B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Direcciones'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.flagGreen,
                                side: const BorderSide(color: AppColors.flagGreen),
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                                shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const TabBar(
                        isScrollable: true,
                        indicatorColor: AppColors.flagGreen,
                        labelColor: AppColors.flagGreen,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: 'Historia'),
                          Tab(text: 'Menú'),
                          Tab(text: 'Horarios'),
                          Tab(text: 'Reseñas'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            _HistoryTab(description: place.description),
                            const _MenuTab(),
                            const _ScheduleTab(),
                            const _ReviewsTab(),
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
          Expanded(
            flex: 2,
            child: _GalleryImage(url: imageUrl),
          ),
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
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFDDE2E6)),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleActionButton({
    required this.icon,
    required this.onPressed,
  });

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
    return SingleChildScrollView(
      child: Text(
        description,
        style: AppTextStyles.bodyMuted.copyWith(
          color: const Color(0xFF4D555D),
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
            description: 'Porción tradicional con arepa, papa criolla y ají casero.',
          ),
          _MenuItemCard(
            title: 'Ajiaco Cundinamarqués',
            price: '\$22,000 COP',
            description: 'Sopa espesa con pollo, papa y guasca, ideal para clima frío.',
          ),
          _MenuItemCard(
            title: 'Chocolate Campesino',
            price: '\$9,000 COP',
            description: 'Bebida caliente con queso y almojábana recién horneada.',
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
    return const SingleChildScrollView(
      child: _HoursCard(),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _ReviewTile(
          name: 'Luisa M.',
          comment: 'Muy bonito, excelente atención y comida típica deliciosa.',
        ),
        _ReviewTile(
          name: 'Camilo R.',
          comment: 'Lugar recomendado para turistas, limpio y con buen ambiente.',
        ),
        _ReviewTile(
          name: 'Natalia P.',
          comment: 'La vista y el servicio son increíbles. Volvería sin duda.',
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: AppRadii.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(color: Color(0xFF5A646D))),
        ],
      ),
    );
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
        color: const Color(0xFFF6F8F9),
        borderRadius: AppRadii.md,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horarios', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Lunes - Viernes: 8:00 AM - 6:00 PM'),
          Text('Sábado: 9:00 AM - 7:00 PM'),
          Text('Domingo: 9:00 AM - 5:00 PM'),
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
        color: const Color(0xFFF8F9FA),
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
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFDDE2E6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(price, style: const TextStyle(color: AppColors.primaryTerracotta)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFF666E76), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
