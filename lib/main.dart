import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/providers/audio_provider.dart';
import 'package:quetame_turismo/providers/event_provider.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/place_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
import 'package:quetame_turismo/screens/main_screen.dart';
import 'package:quetame_turismo/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que el motor de Flutter esté listo antes de arrancar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con la configuración automática que creamos
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()..initialize()),
      ],
      child: const QuetameTurismoApp(),
    ),
  );
}

class QuetameTurismoApp extends StatelessWidget {
  const QuetameTurismoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Quetame Turismo Bicentenario',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
    );
  }
}
