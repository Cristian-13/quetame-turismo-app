import 'package:flutter/material.dart';
import 'package:quetame_turismo/models/place_model.dart';

class PlaceProvider extends ChangeNotifier {
  final List<PlaceModel> _places = const [
    PlaceModel(
      id: 'p1',
      name: 'Iglesia Parroquial',
      description:
          'Templo tradicional del casco urbano, punto de encuentro historico y cultural de Quetame.',
      category: PlaceCategory.historia,
      imageUrl:
          'https://images.unsplash.com/photo-1518998053901-5348d3961a04?auto=format&fit=crop&w=1200&q=60',
      latitude: 4.3318,
      longitude: -73.8656,
      phone: '+573001234567',
    ),
    PlaceModel(
      id: 'p2',
      name: 'Parque Principal',
      description:
          'Espacio central ideal para descansar, conocer comercio local y disfrutar actividades comunitarias.',
      category: PlaceCategory.naturaleza,
      imageUrl:
          'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=1200&q=60',
      latitude: 4.3313,
      longitude: -73.8649,
      phone: '+573011234567',
    ),
    PlaceModel(
      id: 'p3',
      name: 'Mirador del Canon',
      description:
          'Punto panoramico con vista al valle y a la geografia montanosa de la region.',
      category: PlaceCategory.mirador,
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=60',
      latitude: 4.3332,
      longitude: -73.8669,
      phone: '+573021234567',
    ),
  ];

  List<PlaceModel> get places => List.unmodifiable(_places);
}
