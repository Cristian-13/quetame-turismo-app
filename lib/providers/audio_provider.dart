import 'package:flutter/material.dart';

class AudioProvider extends ChangeNotifier {
  bool _isPlaying = false;
  String _currentTrackTitle = 'Parada 1: El Mirador';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 3, seconds: 30);

  bool get isPlaying => _isPlaying;
  String get currentTrackTitle => _currentTrackTitle;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void skipForward() {
    final next = _currentPosition + const Duration(seconds: 15);
    _currentPosition = next > _totalDuration ? _totalDuration : next;
    notifyListeners();
  }

  void skipBackward() {
    final previous = _currentPosition - const Duration(seconds: 15);
    _currentPosition = previous.isNegative ? Duration.zero : previous;
    notifyListeners();
  }
}
