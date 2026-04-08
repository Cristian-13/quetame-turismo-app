import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

class AppRadii {
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(24));
  static const BorderRadius topSheet = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  );

  const AppRadii._();
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  const AppShadows._();
}

class AppTextStyles {
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyMuted = TextStyle(
    color: Color(0xFF5F6469),
    fontSize: 13,
  );

  const AppTextStyles._();
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTerracotta),
      scaffoldBackgroundColor: AppColors.backgroundCream,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryTerracotta,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: Color(0x33A3402D),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: AppColors.primaryTerracotta),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTerracotta,
        brightness: Brightness.dark,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
      ),
      useMaterial3: true,
    );
  }

  const AppTheme._();
}
