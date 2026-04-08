import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/features/map/presentation/widgets/map_header.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
import 'package:quetame_turismo/screens/events_screen.dart';
import 'package:quetame_turismo/screens/map_screen.dart';
import 'package:quetame_turismo/screens/routes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          MapHeader(
            isDarkMode: isDarkMode,
            onToggleTheme: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: const [
                MapScreen(),
                RoutesScreen(),
                EventsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Rutas',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Eventos',
          ),
        ],
      ),
    );
  }
}
