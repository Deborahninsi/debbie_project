import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  bool _isRefreshing = false;
  String? _lastRefreshMessage;
  DateTime? _lastRefreshTime;

  bool get isRefreshing => _isRefreshing;
  String? get lastRefreshMessage => _lastRefreshMessage;
  DateTime? get lastRefreshTime => _lastRefreshTime;

  void setRefreshing(bool refreshing, {String? message}) {
    _isRefreshing = refreshing;
    if (message != null) {
      _lastRefreshMessage = message;
    }
    if (!refreshing) {
      _lastRefreshTime = DateTime.now();
    }
    notifyListeners();
  }

  bool shouldRefresh({Duration threshold = const Duration(minutes: 5)}) {
    if (_lastRefreshTime == null) return true;
    return DateTime.now().difference(_lastRefreshTime!) > threshold;
  }

  void clearRefreshState() {
    _isRefreshing = false;
    _lastRefreshMessage = null;
    _lastRefreshTime = null;
    notifyListeners();
  }
}
