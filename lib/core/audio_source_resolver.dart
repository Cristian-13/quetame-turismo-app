import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Resuelve URLs y rutas de assets para [AudioPlayer] en móvil y Web.
class AudioSourceResolver {
  const AudioSourceResolver._();

  /// URLs con CORS habilitado (requerido por audioplayers en Web).
  static const String _webFallbackMp3 =
      'https://interactive-examples.mdn.mozilla.net/media/cc0-audio/t-rex-roar.mp3';

  /// Normaliza la URL antes de reproducir (p. ej. reemplaza fuentes sin CORS en Web).
  static String normalizeUrl(String urlOrPath) {
    final trimmed = urlOrPath.trim();
    if (trimmed.isEmpty) return trimmed;

    if (!kIsWeb) return trimmed;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://')) {
      return 'https://${trimmed.substring('http://'.length)}';
    }
    if (lower.startsWith('https://')) {
      if (lower.contains('soundhelix.com')) {
        return _webFallbackMp3;
      }
      return trimmed;
    }

    if (trimmed.startsWith('assets/') || trimmed.startsWith('/')) {
      return trimmed;
    }
    return _webFallbackMp3;
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
