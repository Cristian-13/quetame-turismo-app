import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';

/// Catálogo base de ubicaciones reales de Quetame y Puente Quetame.
class MapEntityCatalog {
  MapEntityCatalog._();

  static final List<MapEntity> ubicacionesQuetame = [
    // Casco Urbano - Quetame
    MapEntity(
      id: 'q_01',
      nombre: 'Parque Principal de Quetame',
      latitud: 4.33025,
      longitud: -73.86470,
      categoria: 'Cultura',
      descripcion:
          'Epicentro cultural y punto de encuentro tradicional del municipio.',
      imagenUrl:
          'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6',
    ),
    MapEntity(
      id: 'q_02',
      nombre: 'Iglesia Nuestra Señora del Tránsito',
      latitud: 4.33045,
      longitud: -73.86445,
      categoria: 'Historia',
      descripcion: 'Templo parroquial histórico, pilar de la arquitectura local.',
      imagenUrl:
          'https://images.unsplash.com/photo-1548625361-ec853018890c',
    ),
    MapEntity(
      id: 'q_03',
      nombre: 'Alcaldía Municipal',
      latitud: 4.33010,
      longitud: -73.86485,
      categoria: 'Servicios',
      descripcion: 'Centro administrativo del gobierno local de Quetame.',
      imagenUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
    ),
    MapEntity(
      id: 'q_04',
      nombre: 'Hospital Nuestra Señora del Tránsito',
      latitud: 4.33100,
      longitud: -73.86505,
      categoria: 'Servicios',
      descripcion: 'Centro principal de atención médica del casco urbano.',
      imagenUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
    ),
    MapEntity(
      id: 'q_05',
      nombre: 'Mirador Sendero La Torre',
      latitud: 4.33150,
      longitud: -73.86200,
      categoria: 'Naturaleza',
      descripcion:
          'Ruta ecológica de ascenso con vista panorámica al valle del Río Negro.',
      imagenUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
    ),
    // Centro Poblado - Puente Quetame
    MapEntity(
      id: 'pq_01',
      nombre: 'Puente Colgante de Puente Quetame',
      latitud: 4.31605,
      longitud: -73.83400,
      categoria: 'Historia',
      descripcion: 'Estructura colgante icónica sobre el Río Negro.',
      imagenUrl:
          'https://images.unsplash.com/photo-1513438205128-16af16280739',
    ),
    MapEntity(
      id: 'pq_02',
      nombre: 'Iglesia de Puente Quetame',
      latitud: 4.31580,
      longitud: -73.83450,
      categoria: 'Historia',
      descripcion: 'Sede parroquial del centro poblado.',
      imagenUrl:
          'https://images.unsplash.com/photo-1548625361-ec853018890c',
    ),
    MapEntity(
      id: 'pq_03',
      nombre: 'Institución Educativa Fray José Ledo',
      latitud: 4.31650,
      longitud: -73.83505,
      categoria: 'Cultura',
      descripcion: 'Colegio principal de Puente Quetame.',
      imagenUrl:
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1',
    ),
    MapEntity(
      id: 'pq_04',
      nombre: 'Puesto de Salud Puente Quetame',
      latitud: 4.31555,
      longitud: -73.83420,
      categoria: 'Servicios',
      descripcion: 'Atención primaria en salud sobre la Vía al Llano.',
      imagenUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
    ),
    MapEntity(
      id: 'pq_05',
      nombre: 'Ribera del Río Negro',
      latitud: 4.31750,
      longitud: -73.83500,
      categoria: 'Naturaleza',
      descripcion: 'Cuerpo hídrico que atraviesa el corredor vial.',
      imagenUrl:
          'https://images.unsplash.com/photo-1437482078695-73f5af6e68fd',
    ),
    MapEntity(
      id: 'pq_06',
      nombre: 'Fábrica de Pan de Sagú Tradicional',
      latitud: 4.31590,
      longitud: -73.83350,
      categoria: 'Gastronomía',
      descripcion:
          'Punto de amasijos tradicionales típicos de la región oriental.',
      imagenUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff',
    ),
    MapEntity(
      id: 'pq_07',
      nombre: 'Vía de Acceso Páramo de las Burras',
      latitud: 4.31200,
      longitud: -73.84500,
      categoria: 'Naturaleza',
      descripcion:
          'Inicio del sendero hacia el ecosistema de páramo local.',
      imagenUrl:
          'https://images.unsplash.com/photo-1501504905252-473c47e087f8',
    ),
  ];

  static List<MapEntity> buildFromFirestoreSites(List<FirestoreMapSite> sites) {
    final turismo = sites.map(MapEntity.fromFirestore).toList(growable: true);
    final existingIds = turismo.map((e) => e.id).toSet();
    for (final marker in ubicacionesQuetame) {
      if (!existingIds.contains(marker.id)) {
        turismo.add(marker);
      }
    }
    return turismo;
  }
}
