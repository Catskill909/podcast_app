import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { initializing, online, offline }

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  NetworkStatus _status = NetworkStatus.initializing;
  NetworkStatus get status => _status;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    final dynamic result = await _connectivity.checkConnectivity();
    ConnectivityResult connectivity;
    if (result is ConnectivityResult) {
      connectivity = result;
    } else if (result is List<ConnectivityResult>) {
      connectivity = result.isNotEmpty ? result.first : ConnectivityResult.none;
    } else {
      connectivity = ConnectivityResult.none;
    }
    _status = _getStatusFromResult(connectivity);
    notifyListeners();
    _connectivity.onConnectivityChanged.listen((dynamic result) {
      ConnectivityResult connectivity;
      if (result is ConnectivityResult) {
        connectivity = result;
      } else if (result is List<ConnectivityResult>) {
        connectivity = result.isNotEmpty ? result.first : ConnectivityResult.none;
      } else {
        connectivity = ConnectivityResult.none;
      }
      final newStatus = _getStatusFromResult(connectivity);
      if (newStatus != _status) {
        _status = newStatus;
        notifyListeners();
      }
    });
  }

  NetworkStatus _getStatusFromResult(ConnectivityResult result) {
    return (result == ConnectivityResult.none)
        ? NetworkStatus.offline
        : NetworkStatus.online;
  }
}
