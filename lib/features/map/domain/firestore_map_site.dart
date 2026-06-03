import 'package:quetame_turismo/core/content/quetame_cdn_urls.dart';
import 'package:quetame_turismo/models/place_model.dart';

/// Sitio turístico leído desde Firestore (`sitios`).
class FirestoreMapSite {
  final String id;
  final String nombre;
  final String descripcion;
  final String historia;
  final String horarios;
  final String horaApertura;
  final String horaCierre;
  final String telefono;
  final String menuUrl;
  final String categoriaRaw;
  final String category;
  final String imagenUrl;
  final double latitud;
  final double longitud;

  const FirestoreMapSite({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.historia,
    required this.horarios,
    required this.horaApertura,
    required this.horaCierre,
    required this.telefono,
    required this.menuUrl,
    required this.categoriaRaw,
    required this.category,
    required this.imagenUrl,
    required this.latitud,
    required this.longitud,
  });

  /// URL lista para [Image.network] o `null` si no hay imagen en Firebase/CDN.
  String? get displayImageUrl => QuetameCdnUrls.resolveImage(imagenUrl);

  String? get displayMenuUrl => QuetameCdnUrls.resolveMenu(menuUrl);

  static FirestoreMapSite? fromMap(String docId, Map<String, dynamic> data) {
    final nombre = (data['nombre'] ?? '').toString().trim();
    final descripcion = (data['descripcion'] ?? '').toString().trim();
    final historia = (data['historia'] ?? '').toString().trim();
    final horarios = (data['horarios'] ?? '').toString().trim();
    final horaApertura = (data['hora_apertura'] ?? '').toString().trim();
    final horaCierre = (data['hora_cierre'] ?? '').toString().trim();
    final telefono =
        (data['telefono'] ?? data['phone'] ?? '').toString().trim();
    final menuUrl = (data['menu_url'] ?? '').toString().trim();
    final categoriaRaw = (data['categoria'] ?? '').toString();
    final imagenUrl = (data['imagen_url'] ?? data['imageUrl'] ?? '')
        .toString()
        .trim();
    final lat = data['latitud'] ?? data['latitude'];
    final lng = data['longitud'] ?? data['longitude'];

    if (nombre.isEmpty || lat == null || lng == null) {
      return null;
    }

    final latitud = lat is num ? lat.toDouble() : double.tryParse('$lat');
    final longitud = lng is num ? lng.toDouble() : double.tryParse('$lng');
    if (latitud == null || longitud == null) {
      return null;
    }

    return FirestoreMapSite(
      id: docId,
      nombre: nombre,
      descripcion: descripcion,
      historia: historia,
      horarios: horarios,
      horaApertura: horaApertura,
      horaCierre: horaCierre,
      telefono: telefono,
      menuUrl: menuUrl,
      categoriaRaw: categoriaRaw,
      category: normalizeCategory(categoriaRaw),
      imagenUrl: imagenUrl,
      latitud: latitud,
      longitud: longitud,
    );
  }

  PlaceModel toPlaceModel() {
    return PlaceModel(
      id: id,
      name: nombre,
      description: descripcion,
      category: toPlaceCategory(category),
      rawCategory: categoriaRaw,
      imageUrl: displayImageUrl,
      latitude: latitud,
      longitude: longitud,
      phone: telefono.isEmpty ? null : telefono,
      historia: historia,
      horarios: horarios,
      horaApertura: horaApertura.isEmpty ? null : horaApertura,
      horaCierre: horaCierre.isEmpty ? null : horaCierre,
      menuUrl: displayMenuUrl,
    );
  }
}

String normalizeCategory(String raw) {
  final value = raw.trim().toLowerCase();
  switch (value) {
    case 'historia':
      return 'Historia';
    case 'naturaleza':
      return 'Naturaleza';
    case 'mirador':
      return 'Mirador';
    case 'gastronomia':
    case 'gastronomía':
    case 'restaurante':
    case 'comida':
      return 'Gastronomía';
    default:
      return 'Naturaleza';
  }
}

PlaceCategory toPlaceCategory(String category) {
  switch (category) {
    case 'Historia':
      return PlaceCategory.historia;
    case 'Mirador':
      return PlaceCategory.mirador;
    case 'Gastronomía':
      return PlaceCategory.gastronomia;
    case 'Naturaleza':
    default:
      return PlaceCategory.naturaleza;
  }
}
