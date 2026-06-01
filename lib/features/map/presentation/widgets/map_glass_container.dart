import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_theme_extension.dart';

/// Contenedor con efecto cristal adaptable a modo claro/oscuro.
class MapGlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double? backgroundOpacity;

  const MapGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.blurSigma = 10,
    this.backgroundOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final extras = theme.extension<QuetameThemeColors>();
    final opacity = backgroundOpacity ?? (isDark ? 0.55 : 0.7);
    final fill = theme.colorScheme.surface.withValues(alpha: opacity);
    final borderColor = (extras?.elevatedBorder ?? theme.colorScheme.outline)
        .withValues(alpha: isDark ? 0.5 : 0.35);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
