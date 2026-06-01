import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/core/widgets/quetame_fact_cycler.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_glass_container.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/screens/events_screen.dart';
import 'package:quetame_turismo/screens/map_screen.dart';
import 'package:quetame_turismo/screens/routes_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/theme_notifier.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1516738901171-8eb4fc13bd20?auto=format&fit=crop&w=1400&q=80';

  late final AnimationController _introController;
  late final List<Animation<Offset>> _cardSlides;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..forward();
    _cardSlides = List.generate(
      3,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _introController,
          curve: Interval(0.12 + (i * 0.12), 0.72 + (i * 0.12), curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  void _openSection(
    BuildContext context, {
    required String title,
    required Widget child,
    void Function()? onOpen,
    void Function()? onClose,
  }) {
    onOpen?.call();
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => _SectionShell(title: title, child: child),
          ),
        )
        .then((_) => onClose?.call());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            leading: const SizedBox.shrink(),
            leadingWidth: 0,
            title: const Text('Quetame 200 Años'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: _GlassThemeToggleButton(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _heroImageUrl,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: Text(
                      'Explora rutas ecológicas y patrimonio de Quetame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: QuetameFactCycler(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  SlideTransition(
                    position: _cardSlides[0],
                    child: _HomeEntryCard(
                      title: 'Mapa Turístico',
                      subtitle: 'Explora puntos de interés con navegación guiada.',
                      imageUrl:
                          'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=1200&q=80',
                      icon: Icons.map_rounded,
                      onTap: () => _openSection(
                        context,
                        title: 'Mapa Turístico',
                        child: const MapScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SlideTransition(
                    position: _cardSlides[1],
                    child: _HomeEntryCard(
                      title: 'Rutas Ecológicas',
                      subtitle: 'Telemetry en tiempo real desde tu ubicación.',
                      imageUrl:
                          'https://images.unsplash.com/photo-1472396961693-142e6e269027?auto=format&fit=crop&w=1200&q=80',
                      icon: Icons.forest_rounded,
                      onTap: () => _openSection(
                        context,
                        title: 'Rutas Ecológicas',
                        child: const RoutesScreen(),
                        onOpen: () => context.read<RouteProvider>().setRoutesTabActive(true),
                        onClose: () => context.read<RouteProvider>().setRoutesTabActive(false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SlideTransition(
                    position: _cardSlides[2],
                    child: _HomeEntryCard(
                      title: 'Agenda Bicentenario',
                      subtitle: 'Eventos culturales organizados por cronograma.',
                      imageUrl:
                          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
                      icon: Icons.event_rounded,
                      onTap: () => _openSection(
                        context,
                        title: 'Agenda Bicentenario',
                        child: const EventsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEntryCard extends StatelessWidget {
  const _HomeEntryCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 186,
        maxHeight: 186,
        maxWidth: 600,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(icon, color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassThemeToggleButton extends StatelessWidget {
  const _GlassThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return MapGlassContainer(
          borderRadius: BorderRadius.circular(22),
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: toggleAppTheme,
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppColors.goldPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(child: child),
    );
  }
}
