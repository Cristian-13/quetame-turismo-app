import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:quetame_turismo/core/audio_source_resolver.dart';

class AudioAutoplayBlockedException implements Exception {
  const AudioAutoplayBlockedException();
}

class AudioProvider extends ChangeNotifier {
  AudioProvider() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      unawaited(
        _player.setAudioContext(
          AudioContext(
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: {AVAudioSessionOptions.mixWithOthers},
            ),
          ),
        ),
      );
    }
    if (kIsWeb) {
      unawaited(_player.setReleaseMode(ReleaseMode.stop));
    }
    _positionSub = _player.onPositionChanged.listen((d) {
      _currentPosition = d;
      _throttledNotify();
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
  Timer? _notifyThrottle;

  bool get isPlaying => _isPlaying;
  String get currentTrackTitle => _currentTrackTitle;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get activeRouteId => _activeRouteId;

  void _throttledNotify() {
    _notifyThrottle ??= Timer(const Duration(milliseconds: 250), () {
      _notifyThrottle = null;
      notifyListeners();
    });
  }

  /// En Web usa [play] en un solo paso para no perder el gesto del usuario (autoplay).
  Future<void> _startPlayback(Source source) async {
    await _player.setVolume(1.0);
    if (kIsWeb) {
      await _player.play(source);
      return;
    }
    await _player.play(source);
  }

  Future<void> playRouteAudio(
    String routeId,
    String url, {
    String? trackTitle,
  }) async {
    try {
      final resolvedUrl = AudioSourceResolver.normalizeUrl(url);

      if (_activeRouteId == routeId && _loadedUrl == resolvedUrl) {
        if (_totalDuration > Duration.zero &&
            _currentPosition >=
                _totalDuration - const Duration(milliseconds: 400)) {
          await _player.seek(Duration.zero);
        }
        await _player.resume();
        return;
      }

      if (trackTitle != null) {
        _currentTrackTitle = trackTitle;
      }

      final source = AudioSourceResolver.resolve(resolvedUrl);
      _activeRouteId = routeId;
      _loadedUrl = resolvedUrl;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _isPlaying = false;
      notifyListeners();

      if (!kIsWeb) {
        await _player.stop();
      }

      await _startPlayback(source);
    } catch (e, st) {
      debugPrint('playRouteAudio error: $e\n$st');
      if (kIsWeb && _isWebAutoplayBlockedError(e)) {
        throw const AudioAutoplayBlockedException();
      }
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

  bool _isWebAutoplayBlockedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('notallowederror') ||
        message.contains('the play() request was interrupted') ||
        message.contains('user gesture');
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
    _notifyThrottle?.cancel();
    unawaited(_positionSub?.cancel());
    unawaited(_durationSub?.cancel());
    unawaited(_stateSub?.cancel());
    unawaited(_completeSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
