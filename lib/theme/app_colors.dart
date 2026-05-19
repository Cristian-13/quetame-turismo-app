import 'package:flutter/material.dart';

/// Paleta «El Dorado de los 200 años» — identidad bicentenario profesional.
class AppColors {
  // —— Dorado principal ——
  static const Color goldPrimary = Color(0xFFD9A006);
  static const Color goldDeep = Color(0xFFA67C00);
  static const Color goldLight = Color(0xFFF7E792);
  static const Color goldMuted = Color(0xFFCBB98B);

  // —— Acentos complementarios ——
  static const Color bronze = Color(0xFF8B6914);
  static const Color champagne = Color(0xFFFDF8EB);

  // —— Fondos y superficies ——
  static const Color background = champagne;
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF616161);
  static const Color elevatedBorder = borderLight;
  static const Color surface = Color(0xFFF5F0E6);
  static const Color surfaceVariant = Color(0xFFEDE6D6);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = cardSurface;
  static const Color elevatedShadow = Color(0x26A67C00);

  // —— Texto ——
  static const Color onBackground = Color(0xFF2C2416);
  static const Color onSurface = Color(0xFF3D3524);
  static const Color onSurfaceMuted = Color(0xFF6B5E4A);
  static const Color outline = Color(0xFFD9CEB8);
  static const Color outlineVariant = Color(0xFFE8DFC8);

  // —— Badge de conexión (alto contraste sobre header dorado) ——
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusOnlineText = Color(0xFF374151);
  static const Color statusOfflineBg = Color(0xFF4B5563);
  static const Color statusOfflineText = Color(0xFFF3F4F6);

  // —— Estados semánticos ——
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  // —— Modo oscuro (tonos bronce profundo) ——
  static const Color darkBackground = Color(0xFF1A160C);
  static const Color darkSurface = Color(0xFF2A2418);
  static const Color darkSurfaceVariant = Color(0xFF3D3524);

  // —— Categorías del mapa ——
  static const Color categoryHistoria = goldDeep;
  static const Color categoryNaturaleza = goldPrimary;
  static const Color categoryMirador = goldMuted;
  static const Color categoryGastronomia = bronze;

  // —— Gradientes UI ——
  static const List<Color> gradientHero = [goldLight, goldDeep];
  static const List<Color> gradientRoutePrimary = [goldLight, goldDeep];
  static const List<Color> gradientRouteSecondary = [goldMuted, goldDeep];

  // —— Badges de dificultad en rutas ——
  static const Color difficultyModerateBg = Color(0xFFF7E792);
  static const Color difficultyModerateFg = goldDeep;
  static const Color difficultyHardBg = Color(0xFFFFEDD5);
  static const Color difficultyHardFg = bronze;

  // —— Alias de compatibilidad ——
  static const Color flagGreen = goldPrimary;
  static const Color primaryTerracotta = bronze;
  static const Color secondaryGold = goldMuted;
  static const Color backgroundCream = background;
  static const Color earthAccent = bronze;

  const AppColors._();
}
