import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Riverpod provider to check internet connectivity status in real-time
final connectivityProvider = StateNotifierProvider.autoDispose<ConnectivityNotifier, ConnectivityResult>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityResult> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(ConnectivityResult.none) {
    _init();
  }

  Future<void> _init() async {
    final initial = await Connectivity().checkConnectivity();
    if (!mounted) return;
    state = initial.isNotEmpty ? initial.first : ConnectivityResult.none;

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      state = results.isNotEmpty ? results.first : ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
