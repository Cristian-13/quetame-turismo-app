import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _sub = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _onConnectivityChanged(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final next = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
    if (next == _isConnected) return;
    _isConnected = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

