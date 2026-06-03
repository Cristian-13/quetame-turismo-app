import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:quetame_turismo/core/content/quetame_cdn_urls.dart';

/// Resuelve URLs del CDN y rutas locales para [AudioPlayer] en móvil y Web.
class AudioSourceResolver {
  const AudioSourceResolver._();

  static String normalizeUrl(String urlOrPath) {
    final trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) return trimmed;

    final cdn = QuetameCdnUrls.resolveAudio(trimmed);
    if (cdn != null) return cdn;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      if (kIsWeb && trimmed.toLowerCase().contains('soundhelix.com')) {
        return QuetameCdnUrls.routeAudioguide('la_torre') ?? trimmed;
      }
      return trimmed.startsWith('http://')
          ? 'https://${trimmed.substring('http://'.length)}'
          : trimmed;
    }

    return trimmed;
  }

  static Source resolve(String urlOrPath) {
    final trimmed = normalizeUrl(urlOrPath);
    if (trimmed.isEmpty) {
      throw ArgumentError('La URL de audio no puede estar vacía');
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return UrlSource(trimmed);
    }

    if (kIsWeb) {
      if (trimmed.startsWith('assets/')) {
        return UrlSource('/$trimmed');
      }
      if (trimmed.startsWith('/')) {
        return UrlSource(trimmed);
      }
      return UrlSource('/assets/$trimmed');
    }

    var assetPath = trimmed;
    if (assetPath.startsWith('assets/')) {
      assetPath = assetPath.substring('assets/'.length);
    }
    return AssetSource(assetPath);
  }
}
