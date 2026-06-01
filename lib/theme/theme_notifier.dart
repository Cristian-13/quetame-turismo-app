import 'package:flutter/material.dart';

/// Controlador global de tema (light / dark) para toda la app.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void toggleAppTheme() {
  themeNotifier.value = themeNotifier.value == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;
}
