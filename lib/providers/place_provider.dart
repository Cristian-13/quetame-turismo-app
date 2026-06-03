import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quetame_turismo/core/content/firestore_fields.dart';
import 'package:quetame_turismo/core/content/quetame_cdn_urls.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_categories.dart';
import 'package:quetame_turismo/features/map/domain/map_entity_type.dart';
import 'package:quetame_turismo/models/place_model.dart';

class PlaceProvider extends ChangeNotifier {
  PlaceProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    loadPlaces();
  }

  final FirebaseFirestore _firestore;
  final List<PlaceModel> _places = [];

  bool _isLoading = false;
  String? _error;

  List<PlaceModel> get places => List.unmodifiable(_places);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('places').get();

      final loaded = snapshot.docs.map((doc) {
        final data = doc.data();
        return _placeFromFirestore(doc.id, data);
      }).toList();

      _places
        ..clear()
        ..addAll(loaded);
    } catch (e) {
      _error = e.toString();
      _places.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

PlaceModel _placeFromFirestore(String docId, Map<String, dynamic> data) {
  final categoryRaw = (data['categoria'] ?? data['category'] ?? '')
      .toString()
      .trim()
      .toLowerCase();
  final categoria = MapEntityCategories.normalize(categoryRaw);
  final category = switch (categoria) {
    MapEntityCategories.historia => PlaceCategory.historia,
    MapEntityCategories.gastronomia => PlaceCategory.gastronomia,
    MapEntityCategories.naturaleza => PlaceCategory.naturaleza,
    _ => PlaceCategory.naturaleza,
  };

  final lat = data['latitude'] ?? data['latitud'];
  final lng = data['longitude'] ?? data['longitud'];
  final rawImage = FirestoreFields.readString(data, [
    'imagen_presentacion_url',
    'imagenPresentacionUrl',
    'imagen_url',
    'imageUrl',
  ]);
  final rawMenu = FirestoreFields.readString(data, [
    'imagen_menu_url',
    'imagenMenuUrl',
    'menu_url',
    'menuUrl',
  ]);
  final rawHoraApertura = FirestoreFields.readString(data, [
    'hora_apertura',
    'horaApertura',
  ]);
  final rawHoraCierre = FirestoreFields.readString(data, [
    'hora_cierre',
    'horaCierre',
  ]);
  final tipo = (data['tipo'] ?? 'sitio').toString();

  return PlaceModel(
    id: (data['id'] ?? docId).toString(),
    name: (data['name'] ?? data['nombre'] ?? '').toString(),
    description: (data['description'] ?? data['descripcion'] ?? '').toString(),
    category: category,
    rawCategory: categoria,
    entityType: parseEntityType(tipo),
    imageUrl: QuetameCdnUrls.resolveImage(rawImage),
    latitude: (lat is num) ? lat.toDouble() : double.parse(lat.toString()),
    longitude: (lng is num) ? lng.toDouble() : double.parse(lng.toString()),
    phone: data['phone']?.toString() ?? data['telefono']?.toString(),
    historia: data['historia']?.toString(),
    horarios: data['horarios']?.toString(),
    horaApertura: rawHoraApertura.isEmpty ? null : rawHoraApertura,
    horaCierre: rawHoraCierre.isEmpty ? null : rawHoraCierre,
    menuUrl: QuetameCdnUrls.resolveMenu(rawMenu),
  );
}
