import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initConnectivity();
    Connectivity().onConnectivityChanged.listen(
      (_) => _checkInternetConnection(),
    );
  }

  Future<void> _initConnectivity() async => _checkInternetConnection();

  Future<void> _checkInternetConnection() async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (_isConnected != hasInternet) {
      _isConnected = hasInternet;
      notifyListeners();
    }
  }
}
