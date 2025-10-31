import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _controller.stream;

  NetworkService() {
    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() => _controller.close();
}
