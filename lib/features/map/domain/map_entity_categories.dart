/// Categorías oficiales del mapa (Firestore, minúsculas).
class MapEntityCategories {
  MapEntityCategories._();

  static const String todos = 'todos';
  static const String cultura = 'cultura';
  static const String historia = 'historia';
  static const String servicios = 'servicios';
  static const String naturaleza = 'naturaleza';
  static const String gastronomia = 'gastronomia';
  static const String sitios = 'sitios';

  static const List<String> oficiales = [
    cultura,
    historia,
    servicios,
    naturaleza,
    gastronomia,
    sitios,
  ];

  /// Normaliza el valor de `categoria` desde Firestore.
  static String normalize(String raw) {
    final value = _stripAccents(raw.trim().toLowerCase());
    if (value.isEmpty) return sitios;

    switch (value) {
      case 'cultura':
        return cultura;
      case 'historia':
        return historia;
      case 'servicios':
      case 'servicio':
        return servicios;
      case 'naturaleza':
      case 'mirador':
      case 'ecologia':
      case 'ecología':
        return naturaleza;
      case 'gastronomia':
      case 'gastronomía':
      case 'restaurante':
      case 'comida':
        return gastronomia;
      case 'sitios':
      case 'sitio':
      case 'sitios_turisticos':
      case 'turismo':
        return sitios;
      case 'todos':
        return todos;
      default:
        return oficiales.contains(value) ? value : sitios;
    }
  }

  static String displayLabel(String categoria) {
    switch (normalize(categoria)) {
      case cultura:
        return 'Cultura';
      case historia:
        return 'Historia';
      case servicios:
        return 'Servicios';
      case naturaleza:
        return 'Naturaleza';
      case gastronomia:
        return 'Gastronomía';
      case sitios:
        return 'Sitios';
      case todos:
        return 'Todos';
      default:
        return 'Sitios';
    }
  }

  static String _stripAccents(String value) {
    return value
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }
}
