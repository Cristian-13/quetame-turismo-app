enum MapEntityType {
  restaurante,
  sendero,
  sitio,
  cultura,
  historia,
  servicios,
  naturaleza,
  gastronomia,
}

MapEntityType parseEntityType(String raw) {
  final value = raw.trim().toLowerCase();
  return switch (value) {
    'restaurante' => MapEntityType.restaurante,
    'sendero' || 'ruta' || 'ruta_ecologica' => MapEntityType.sendero,
    'cultura' => MapEntityType.cultura,
    'historia' => MapEntityType.historia,
    'servicios' || 'servicio' => MapEntityType.servicios,
    'naturaleza' => MapEntityType.naturaleza,
    'gastronomia' || 'gastronomía' => MapEntityType.gastronomia,
    'sitio' || 'sitios' || 'turismo' || '' => MapEntityType.sitio,
    _ => MapEntityType.sitio,
  };
}
