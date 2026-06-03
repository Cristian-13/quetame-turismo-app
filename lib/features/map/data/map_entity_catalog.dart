import 'package:quetame_turismo/features/map/domain/firestore_map_site.dart';
import 'package:quetame_turismo/features/map/domain/map_entity.dart';

/// Catálogo de entidades del mapa: solo datos provenientes de Firestore (`sitios`).
class MapEntityCatalog {
  MapEntityCatalog._();

  static List<MapEntity> buildFromFirestoreSites(List<FirestoreMapSite> sites) {
    return sites.map(MapEntity.fromFirestore).toList(growable: false);
  }
}
