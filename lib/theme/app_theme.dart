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
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.flagGreen),
      scaffoldBackgroundColor: AppColors.backgroundCream,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.flagGreen,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.flagGreen.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.flagGreen : const Color(0xFF5F6469),
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.flagGreen : const Color(0xFF5F6469),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            );
          },
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.flagGreen,
        brightness: Brightness.dark,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.flagGreen.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.flagGreen : const Color(0xFFB0B8C0),
            );
          },
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.flagGreen : const Color(0xFFB0B8C0),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            );
          },
        ),
      ),
      useMaterial3: true,
    );
  }

  const AppTheme._();
}
