import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> _events = [
    EventModel(
      id: 'e1',
      title: 'Festival del Cafe y Tradicion Campesina',
      description:
          'Muestra gastronomica, musica en vivo y feria de emprendimientos locales.',
      category: EventCategory.cultural,
      day: '12',
      month: 'SEP',
      dayOfWeek: 'Sabado',
      time: '10:00 AM',
      location: 'Parque Principal de Quetame',
      imageUrl:
          'https://images.unsplash.com/photo-1511537190474-41a0a301a51a?auto=format&fit=crop&w=1200&q=60',
      startDateTime: DateTime(2026, 9, 12, 10, 0),
      endDateTime: DateTime(2026, 9, 12, 18, 0),
    ),
    EventModel(
      id: 'e2',
      title: 'Caminata Ecologica al Mirador Alto',
      description:
          'Recorrido guiado con interpretacion ambiental y avistamiento de aves.',
      category: EventCategory.naturaleza,
      day: '20',
      month: 'SEP',
      dayOfWeek: 'Domingo',
      time: '6:30 AM',
      location: 'Salida desde la Casa de la Cultura',
      imageUrl:
          'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=1200&q=60',
      startDateTime: DateTime(2026, 9, 20, 6, 30),
      endDateTime: DateTime(2026, 9, 20, 12, 0),
    ),
  ];

  List<EventModel> get events => List.unmodifiable(_events);
}
