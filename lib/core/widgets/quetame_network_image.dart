import 'package:flutter/material.dart';
import 'package:quetame_turismo/theme/app_colors.dart';

/// Imagen remota con placeholder y estado de error unificados.
class QuetameNetworkImage extends StatelessWidget {
  const QuetameNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.placeholderColor,
    this.filterQuality = FilterQuality.low,
    this.gaplessPlayback = true,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = placeholderColor ?? theme.colorScheme.surfaceContainerHighest;
    final iconColor = theme.colorScheme.onSurfaceVariant;

    Widget child;
    final resolved = url?.trim();
    if (resolved == null || resolved.isEmpty) {
      child = _Placeholder(
        icon: placeholderIcon,
        backgroundColor: bg,
        iconColor: iconColor,
      );
    } else if (width != null || height != null) {
      child = Image.network(
        resolved,
        fit: fit,
        width: width,
        height: height,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        loadingBuilder: (context, imageChild, progress) {
          if (progress == null) return imageChild;
          return ColoredBox(
            color: bg,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _Placeholder(
          icon: Icons.broken_image_outlined,
          backgroundColor: bg,
          iconColor: iconColor,
          showWarning: true,
        ),
      );
    } else {
      child = SizedBox.expand(
        child: Image.network(
          resolved,
          fit: fit,
          gaplessPlayback: gaplessPlayback,
          filterQuality: filterQuality,
          loadingBuilder: (context, imageChild, progress) {
            if (progress == null) return imageChild;
            return ColoredBox(
              color: bg,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.goldPrimary,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _Placeholder(
            icon: Icons.broken_image_outlined,
            backgroundColor: bg,
            iconColor: iconColor,
            showWarning: true,
          ),
        ),
      );
    }

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    return child;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.showWarning = false,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool showWarning;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            if (showWarning) ...[
              const SizedBox(height: 6),
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: iconColor.withValues(alpha: 0.85),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
