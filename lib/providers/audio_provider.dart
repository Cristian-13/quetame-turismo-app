import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioProvider extends ChangeNotifier {
  AudioProvider() {
    _positionSub = _player.onPositionChanged.listen((d) {
      _currentPosition = d;
      notifyListeners();
    });
    _durationSub = _player.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentPosition = _totalDuration;
      notifyListeners();
    });
  }

  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  bool _isPlaying = false;
  String _currentTrackTitle = 'Audioguía de ruta';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _activeRouteId;
  String? _loadedUrl;

  bool get isPlaying => _isPlaying;
  String get currentTrackTitle => _currentTrackTitle;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get activeRouteId => _activeRouteId;

  /// Si [routeId] es distinto al de la sesión actual: [stop], tiempo a cero y nueva URL.
  /// Si es la misma ruta, reanuda desde la posición actual (o desde el inicio si terminó).
  Future<void> playRouteAudio(
    String routeId,
    String url, {
    String? trackTitle,
  }) async {
    try {
      if (_activeRouteId == routeId) {
        if (_totalDuration > Duration.zero &&
            _currentPosition >=
                _totalDuration - const Duration(milliseconds: 400)) {
          await _player.seek(Duration.zero);
        }
        await _player.resume();
        return;
      }

      await _player.stop();
      _activeRouteId = null;
      _loadedUrl = null;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _isPlaying = false;
      if (trackTitle != null) {
        _currentTrackTitle = trackTitle;
      }
      notifyListeners();

      _activeRouteId = routeId;
      _loadedUrl = url;
      await _player.play(UrlSource(url));
    } catch (e, st) {
      debugPrint('playRouteAudio error: $e\n$st');
      await _player.stop();
      _activeRouteId = null;
      _loadedUrl = null;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  Future<void> toggleRoutePlayPause(
    String routeId,
    String url, {
    String? trackTitle,
  }) async {
    if (_isPlaying && _activeRouteId == routeId) {
      await pauseAudio();
      return;
    }
    await playRouteAudio(routeId, url, trackTitle: trackTitle);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipForward() async {
    final next = _currentPosition + const Duration(seconds: 15);
    final cap = _totalDuration > Duration.zero ? _totalDuration : next;
    await seek(next > cap ? cap : next);
  }

  Future<void> skipBackward() async {
    final previous = _currentPosition - const Duration(seconds: 15);
    await seek(previous.isNegative ? Duration.zero : previous);
  }

  @override
  void dispose() {
    unawaited(_positionSub?.cancel());
    unawaited(_durationSub?.cancel());
    unawaited(_stateSub?.cancel());
    unawaited(_completeSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
