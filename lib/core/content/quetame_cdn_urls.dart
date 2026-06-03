/// URLs del CDN jsDelivr para medios de Quetamé Turismo.
class QuetameCdnUrls {
  QuetameCdnUrls._();

  static const String base =
      'https://cdn.jsdelivr.net/gh/PinzonManuel/quetame-turismo-assets@main';

  /// Resuelve ruta relativa o URL absoluta de imagen de sitio/ruta.
  static String? resolveImage(String? raw) => _resolve(raw, defaultFolder: 'imagenes');

  /// Menú de restaurante (carpeta `menus` en el repo de assets).
  static String? resolveMenu(String? raw) => _resolve(raw, defaultFolder: 'menus');

  /// Audioguía de ruta (carpeta `audios`).
  static String? resolveAudio(String? raw) => _resolve(raw, defaultFolder: 'audios');

  static String? routeAudioguide(String routeId) {
    // Las audioguías se cargan exclusivamente desde Firestore (`audios_rutas/{routeId}`).
    return null;
  }

  static String? routeCoverImage(String routeId) {
    final normalized = routeId.trim().toLowerCase();
    final path = switch (normalized) {
      'la_torre' || 'r1' => 'imagenes/la_torre.jpg',
      'paramo_burras' || 'r2' => 'imagenes/paramo_burras.jpg',
      _ => null,
    };
    if (path == null) return null;
    return resolveImage(path);
  }

  static String? _resolve(String? raw, {required String defaultFolder}) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    if (_isAbsoluteUrl(trimmed)) {
      return _normalizeAbsolute(trimmed);
    }

    var path = trimmed.replaceAll('\\', '/');
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (!path.contains('/')) {
      path = '$defaultFolder/$path';
    }

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final encoded = segments.map(Uri.encodeComponent).join('/');
    return '$base/$encoded';
  }

  static bool _isAbsoluteUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  static String _normalizeAbsolute(String url) {
    final lower = url.toLowerCase();
    if (lower.startsWith('http://')) {
      return 'https://${url.substring('http://'.length)}';
    }
    return url;
  }
}
