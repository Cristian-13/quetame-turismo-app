import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Carga masiva temporal: lee `quetame_data_seed.json` y crea/actualiza docs
/// en `places` usando el `id` del JSON como documentId.
Future<void> seedPlacesToFirestoreFromAsset({
  FirebaseFirestore? firestore,
  String assetPath = 'quetame_data_seed.json',
}) async {
  final db = firestore ?? FirebaseFirestore.instance;

  final raw = await rootBundle.loadString(assetPath);
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('El JSON raíz debe ser un objeto.');
  }

  final places = decoded['places'];
  if (places is! List) {
    throw StateError('El JSON debe contener un arreglo `places`.');
  }

  final batch = db.batch();

  for (final item in places) {
    if (item is! Map) continue;
    final place = Map<String, dynamic>.from(item);

    final id = (place['id'] ?? '').toString().trim();
    if (id.isEmpty) {
      throw StateError('Cada place debe tener un `id` no vacío.');
    }

    final docRef = db.collection('places').doc(id);
    batch.set(docRef, place, SetOptions(merge: true));
  }

  await batch.commit();
}

