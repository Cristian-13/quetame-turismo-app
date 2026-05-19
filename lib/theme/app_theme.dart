import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quetame_turismo/theme/app_colors.dart';
import 'package:quetame_turismo/theme/app_theme_extension.dart';

class AppRadii {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
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
      color: Color(0x1AA67C00),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0DA67C00),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  const AppShadows._();
}

class AppTextStyles {
  static TextStyle get sectionTitle => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.onBackground,
      );

  static TextStyle get cardTitle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMuted => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceMuted,
        height: 1.4,
      );

  const AppTextStyles._();
}

class AppTheme {
  static const double _cardRadius = 20;
  static const BorderSide _lightElevatedBorder = BorderSide(
    color: AppColors.borderLight,
    width: 1,
  );
  static const BorderSide _darkElevatedBorder = BorderSide(
    color: AppColors.borderDark,
    width: 1,
  );

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.goldPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.goldLight.withValues(alpha: 0.55),
      onPrimaryContainer: AppColors.goldDeep,
      secondary: AppColors.goldMuted,
      onSecondary: AppColors.onBackground,
      secondaryContainer: AppColors.goldMuted.withValues(alpha: 0.35),
      onSecondaryContainer: AppColors.goldDeep,
      tertiary: AppColors.bronze,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.bronze.withValues(alpha: 0.18),
      onTertiaryContainer: AppColors.goldDeep,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withValues(alpha: 0.12),
      onErrorContainer: AppColors.error,
      surface: AppColors.cardSurface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceMuted,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.elevatedShadow,
      scrim: Colors.black54,
      inverseSurface: AppColors.goldDeep,
      onInverseSurface: AppColors.champagne,
      inversePrimary: AppColors.goldLight,
      surfaceTint: AppColors.goldPrimary,
    );

    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extensions: const [QuetameThemeColors.light],
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.onBackground),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 4,
        shadowColor: AppColors.elevatedShadow,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: _lightElevatedBorder,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.goldPrimary,
          side: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lg),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.goldPrimary.withValues(alpha: 0.18),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: const BorderSide(color: AppColors.goldPrimary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: AppColors.onSurfaceMuted),
        hintStyle: GoogleFonts.poppins(color: AppColors.onSurfaceMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedItemColor: AppColors.goldPrimary,
        unselectedItemColor: AppColors.onSurfaceMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        indicatorColor: AppColors.goldPrimary.withValues(alpha: 0.18),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.goldPrimary : AppColors.onSurfaceMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.goldPrimary : AppColors.onSurfaceMuted,
          );
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.goldPrimary,
        unselectedLabelColor: AppColors.onSurfaceMuted,
        indicatorColor: AppColors.goldPrimary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.goldDeep,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardSurface,
        elevation: 4,
        shadowColor: AppColors.elevatedShadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.xl,
          side: _lightElevatedBorder,
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardSurface,
        elevation: 4,
        shadowColor: AppColors.elevatedShadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.topSheet,
          side: _lightElevatedBorder,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.goldPrimary,
        textColor: AppColors.onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.goldLight,
      onPrimary: AppColors.darkBackground,
      primaryContainer: AppColors.goldDeep,
      onPrimaryContainer: AppColors.goldLight,
      secondary: AppColors.goldMuted,
      onSecondary: AppColors.darkBackground,
      secondaryContainer: AppColors.goldMuted.withValues(alpha: 0.35),
      onSecondaryContainer: AppColors.goldLight,
      tertiary: AppColors.bronze,
      onTertiary: AppColors.darkBackground,
      tertiaryContainer: AppColors.bronze.withValues(alpha: 0.35),
      onTertiaryContainer: AppColors.goldLight,
      error: const Color(0xFFF87171),
      onError: AppColors.darkBackground,
      errorContainer: AppColors.error.withValues(alpha: 0.25),
      onErrorContainer: const Color(0xFFFECACA),
      surface: AppColors.darkSurface,
      onSurface: const Color(0xFFF5F0E6),
      onSurfaceVariant: AppColors.goldMuted,
      outline: const Color(0xFF6B5E4A),
      outlineVariant: const Color(0xFF4A4030),
      shadow: Colors.black,
      scrim: Colors.black87,
      inverseSurface: AppColors.champagne,
      onInverseSurface: AppColors.onSurface,
      inversePrimary: AppColors.goldPrimary,
      surfaceTint: AppColors.goldLight,
    );

    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extensions: const [QuetameThemeColors.dark],
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: _darkElevatedBorder,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.goldLight.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.goldLight : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.goldLight : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.xl,
          side: _darkElevatedBorder,
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black45,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.topSheet,
          side: _darkElevatedBorder,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.borderDark,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: scheme.onSurface,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  const AppTheme._();
}
