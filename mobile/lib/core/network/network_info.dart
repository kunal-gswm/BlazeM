import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks network connectivity status.
class NetworkInfo {
  const NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  /// Returns true if the device has an active network connection.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
  }
}
