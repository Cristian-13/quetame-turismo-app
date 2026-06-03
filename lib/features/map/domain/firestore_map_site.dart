import 'package:quetame_turismo/core/content/quetame_cdn_urls.dart';
import 'package:quetame_turismo/core/content/firestore_fields.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_type.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
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
  final String menuUrlRaw;
  final String tipo;
  final String categoria;
  final String imagenUrlRaw;
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
    required this.menuUrlRaw,
    required this.tipo,
    required this.categoria,
    required this.imagenUrlRaw,
    required this.latitud,
    required this.longitud,
  });

  String? get imagenPresentacionUrl =>
      QuetameCdnUrls.resolveImage(imagenUrlRaw);

  String? get imagenMenuUrl => QuetameCdnUrls.resolveMenu(menuUrlRaw);

  static FirestoreMapSite? fromMap(String docId, Map<String, dynamic> data) {
    final nombre = (data['nombre'] ?? '').toString().trim();
    final descripcion = (data['descripcion'] ?? '').toString().trim();
    final historia = (data['historia'] ?? '').toString().trim();
    final horarios = (data['horarios'] ?? '').toString().trim();
    final horaApertura = FirestoreFields.readString(data, [
      'hora_apertura',
      'horaApertura',
      'hora_apertura_str',
    ]);
    final horaCierre = FirestoreFields.readString(data, [
      'hora_cierre',
      'horaCierre',
      'hora_cierre_str',
    ]);
    final telefono =
        (data['telefono'] ?? data['phone'] ?? '').toString().trim();
    final menuUrlRaw = FirestoreFields.readString(data, [
      'imagen_menu_url',
      'imagenMenuUrl',
      'menu_url',
      'menuUrl',
    ]);
    final tipo = (data['tipo'] ?? 'sitio').toString().trim();
    final categoriaRaw = (data['categoria'] ?? '').toString();
    final imagenUrlRaw = FirestoreFields.readString(data, [
      'imagen_presentacion_url',
      'imagenPresentacionUrl',
      'imagen_url',
      'imageUrl',
    ]);
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
      menuUrlRaw: menuUrlRaw,
      tipo: tipo,
      categoria: MapEntityCategories.normalize(categoriaRaw),
      imagenUrlRaw: imagenUrlRaw,
      latitud: latitud,
      longitud: longitud,
    );
  }

  PlaceModel toPlaceModel() {
    return PlaceModel(
      id: id,
      name: nombre,
      description: descripcion,
      category: toPlaceCategory(categoria),
      rawCategory: categoria,
      entityType: parseEntityType(tipo),
      imageUrl: imagenPresentacionUrl,
      latitude: latitud,
      longitude: longitud,
      phone: telefono.isEmpty ? null : telefono,
      historia: historia,
      horarios: horarios,
      horaApertura: horaApertura.isEmpty ? null : horaApertura,
      horaCierre: horaCierre.isEmpty ? null : horaCierre,
      menuUrl: imagenMenuUrl,
    );
  }
}

PlaceCategory toPlaceCategory(String categoria) {
  switch (MapEntityCategories.normalize(categoria)) {
    case MapEntityCategories.historia:
      return PlaceCategory.historia;
    case MapEntityCategories.gastronomia:
      return PlaceCategory.gastronomia;
    case MapEntityCategories.naturaleza:
      return PlaceCategory.naturaleza;
    case MapEntityCategories.cultura:
    case MapEntityCategories.servicios:
    case MapEntityCategories.sitios:
    default:
      return PlaceCategory.naturaleza;
  }
}
