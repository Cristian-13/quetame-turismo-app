import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final List<EventModel> _events = const [
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
    ),
  ];

  List<EventModel> get events => List.unmodifiable(_events);
}
