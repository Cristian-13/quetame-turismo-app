import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Resuelve URLs y rutas de assets para [AudioPlayer] en móvil y Web.
class AudioSourceResolver {
  const AudioSourceResolver._();

  static Source resolve(String urlOrPath) {
    final trimmed = urlOrPath.trim();
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
