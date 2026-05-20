import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
import 'package:quetame_turismo/screens/events_screen.dart';
import 'package:quetame_turismo/screens/map_screen.dart';
import 'package:quetame_turismo/screens/routes_screen.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<String> _curiosidades = [
    'Quetamé fue fundado en 1556 y celebra más de cuatro siglos de historia.',
    'Su nombre proviene del muisca «quetame», que evoca tierras fértiles y montañosas.',
    'El municipio hace parte del corredor turístico del Sumapaz y la región andina.',
    'En julio de 2025 Quetamé conmemora los 200 años de su independencia.',
  ];

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
            builder: (_) => _SectionShell(
              title: title,
              child: child,
            ),
          ),
        )
        .then((_) => onClose?.call());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curiosidad =
        _curiosidades[DateTime.now().millisecond % _curiosidades.length];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Quetame Turismo',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cambiar tema',
                      onPressed: () =>
                          context.read<ThemeProvider>().toggleTheme(),
                      icon: Icon(
                        theme.brightness == Brightness.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: _CuriosityBanner(text: curiosidad),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildListDelegate([
                  _DashboardActionCard(
                    icon: Icons.map_outlined,
                    title: 'Mapa Turístico',
                    onTap: () => _openSection(
                      context,
                      title: 'Mapa Turístico',
                      child: const MapScreen(),
                    ),
                  ),
                  _DashboardActionCard(
                    icon: Icons.forest_outlined,
                    title: 'Rutas Ecológicas',
                    onTap: () => _openSection(
                      context,
                      title: 'Rutas Ecológicas',
                      child: const RoutesScreen(),
                      onOpen: () => context
                          .read<RouteProvider>()
                          .setRoutesTabActive(true),
                      onClose: () => context
                          .read<RouteProvider>()
                          .setRoutesTabActive(false),
                    ),
                  ),
                  _DashboardActionCard(
                    icon: Icons.storefront_outlined,
                    title: 'Comercio y Servicios',
                    onTap: () => _openSection(
                      context,
                      title: 'Comercio y Servicios',
                      child: const MapScreen(initialCategory: 'Gastronomía'),
                    ),
                  ),
                  _DashboardActionCard(
                    icon: Icons.event_outlined,
                    title: 'Agenda Bicentenario',
                    onTap: () => _openSection(
                      context,
                      title: 'Agenda Bicentenario',
                      child: const EventsScreen(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuriosityBanner extends StatelessWidget {
  final String text;

  const _CuriosityBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldLight.withValues(alpha: 0.95),
            AppColors.goldPrimary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.elevatedShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.goldDeep,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Dato Curioso de Quetame',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.goldDeep,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: AppColors.cardSurface,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.elevatedShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: AppColors.goldPrimary),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
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

class _SectionShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: child,
    );
  }
}
