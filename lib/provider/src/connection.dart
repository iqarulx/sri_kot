import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectionProvider extends ChangeNotifier {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isConnected = false;

  ConnectionProvider() {
    // Initialize the connection check
    _checkConnection();
  }

  // Initialize connection status and listen to changes
  void _checkConnection() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Update connection status based on the result
      if (result.contains(ConnectivityResult.none)) {
        _isConnected = false;
      } else {
        _isConnected = true;
      }
      notifyListeners(); // Notify listeners about the change
    });

    // Check initial connection status
    _checkInitialStatus();
  }

  // Method to check initial connectivity status
  Future<void> _checkInitialStatus() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      _isConnected = false;
    } else {
      _isConnected = true;
    }
    notifyListeners(); // Notify listeners about the initial status
  }

  bool get isConnected => _isConnected;

  // Dispose of the subscription when no longer needed
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
