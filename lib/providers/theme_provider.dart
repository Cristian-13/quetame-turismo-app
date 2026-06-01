import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/theme_notifier.dart';

/// Puente con Provider para pantallas que aún usan [ChangeNotifier].
class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    themeNotifier.addListener(notifyListeners);
  }

  ThemeMode get themeMode => themeNotifier.value;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme() => toggleAppTheme();
}
