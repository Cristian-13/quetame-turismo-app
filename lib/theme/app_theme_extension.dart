import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Colores que deben interpolarse durante el cambio de tema (evita saltos de [Brightness]).
@immutable
class QuetameThemeColors extends ThemeExtension<QuetameThemeColors> {
  const QuetameThemeColors({
    required this.headerBackground,
    required this.headerForeground,
    required this.elevatedSurface,
    required this.elevatedBorder,
  });

  final Color headerBackground;
  final Color headerForeground;
  final Color elevatedSurface;
  final Color elevatedBorder;

  static const QuetameThemeColors light = QuetameThemeColors(
    headerBackground: AppColors.goldPrimary,
    headerForeground: Colors.white,
    elevatedSurface: AppColors.cardSurface,
    elevatedBorder: AppColors.borderLight,
  );

  static const QuetameThemeColors dark = QuetameThemeColors(
    headerBackground: AppColors.darkSurface,
    headerForeground: Color(0xFFE8EDEA),
    elevatedSurface: AppColors.darkSurface,
    elevatedBorder: AppColors.borderDark,
  );

  @override
  QuetameThemeColors copyWith({
    Color? headerBackground,
    Color? headerForeground,
    Color? elevatedSurface,
    Color? elevatedBorder,
  }) {
    return QuetameThemeColors(
      headerBackground: headerBackground ?? this.headerBackground,
      headerForeground: headerForeground ?? this.headerForeground,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      elevatedBorder: elevatedBorder ?? this.elevatedBorder,
    );
  }

  @override
  QuetameThemeColors lerp(ThemeExtension<QuetameThemeColors>? other, double t) {
    if (other is! QuetameThemeColors) return this;
    return QuetameThemeColors(
      headerBackground:
          Color.lerp(headerBackground, other.headerBackground, t)!,
      headerForeground:
          Color.lerp(headerForeground, other.headerForeground, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      elevatedBorder: Color.lerp(elevatedBorder, other.elevatedBorder, t)!,
    );
  }
}
