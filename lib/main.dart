import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quetame_turismo/providers/audio_provider.dart';
import 'package:quetame_turismo/providers/event_provider.dart';
import 'package:quetame_turismo/providers/location_provider.dart';
import 'package:quetame_turismo/providers/network_provider.dart';
import 'package:quetame_turismo/providers/place_provider.dart';
import 'package:quetame_turismo/providers/route_provider.dart';
import 'package:quetame_turismo/providers/theme_provider.dart';
import 'package:quetame_turismo/screens/splash_screen.dart';
import 'package:quetame_turismo/theme/app_theme.dart';
import 'package:quetame_turismo/theme/theme_notifier.dart';
import 'firebase_options.dart';

/// Duración y curva alineadas con la animación interna de [MaterialApp].
const Duration kThemeTransitionDuration = Duration(milliseconds: 600);
const Curve kThemeTransitionCurve = Curves.easeInOutCubic;

/// Ancho máximo en escritorio / PWA para mantener proporciones móviles.
const double kAppMaxContentWidth = 600;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => RouteProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => PlaceProvider()),
          ChangeNotifierProvider(create: (_) => AudioProvider()),
          ChangeNotifierProvider(create: (_) => NetworkProvider()),
          ChangeNotifierProvider(
            create: (_) => LocationProvider()..initialize(),
          ),
        ],
        child: const QuetameTurismoApp(),
      ),
    );
  } catch (e, st) {
    debugPrint('Fatal error during startup: $e');
    debugPrint('$st');
    rethrow;
  }
}

class QuetameTurismoApp extends StatelessWidget {
  const QuetameTurismoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Quetame 200 Años',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeMode,
          themeAnimationDuration: kThemeTransitionDuration,
          themeAnimationCurve: kThemeTransitionCurve,
          home: const SplashScreen(),
          builder: (context, child) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kAppMaxContentWidth),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
