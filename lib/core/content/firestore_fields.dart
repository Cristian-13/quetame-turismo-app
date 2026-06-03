/// Utilidades para leer campos de Firestore con alias en español/camelCase.
class FirestoreFields {
  FirestoreFields._();

  /// Devuelve el primer valor no vacío probando las claves en orden.
  static String readString(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return '';
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
