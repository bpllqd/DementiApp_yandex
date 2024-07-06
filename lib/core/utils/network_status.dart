import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NetworkStatus extends ChangeNotifier {
  late bool _isOnline;

  bool get isOnline => _isOnline;

  Future<void> init() async {
    final result = await Connectivity().checkConnectivity();
    _checkResult(result, checkIdentity: false);
    notifyListeners();
    Connectivity().onConnectivityChanged.listen(_checkResult);
  }

  void _checkResult(List<ConnectivityResult> result,
      {bool checkIdentity = true,}) {
    final status = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
    if (checkIdentity && status == _isOnline) return;
    _isOnline = status;
    notifyListeners();
  }
}
