import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final categoryRaw = (data['category'] ?? '').toString().trim().toLowerCase();
  final category = switch (categoryRaw) {
    'historia' => PlaceCategory.historia,
    'naturaleza' => PlaceCategory.naturaleza,
    'mirador' => PlaceCategory.mirador,
    'gastronomia' => PlaceCategory.gastronomia,
    'gastronomía' => PlaceCategory.gastronomia,
    'restaurante' => PlaceCategory.gastronomia,
    'comida' => PlaceCategory.gastronomia,
    _ => PlaceCategory.naturaleza,
  };

  final lat = data['latitude'];
  final lng = data['longitude'];

  return PlaceModel(
    id: (data['id'] ?? docId).toString(),
    name: (data['name'] ?? '').toString(),
    description: (data['description'] ?? '').toString(),
    category: category,
    rawCategory: categoryRaw,
    imageUrl: (data['imageUrl'] ?? '').toString(),
    latitude: (lat is num) ? lat.toDouble() : double.parse(lat.toString()),
    longitude: (lng is num) ? lng.toDouble() : double.parse(lng.toString()),
    phone: data['phone']?.toString(),
    historia: data['historia']?.toString(),
    horarios: data['horarios']?.toString(),
  );
}
