import 'package:flutter/foundation.dart';

/// A simple notifier that widgets can listen to for any global data change.
class DataChangeNotifier extends ChangeNotifier {
  /// Call this method to notify all listeners.
  void notify() {
    notifyListeners();
  }
}

// A single, global instance of the notifier that the whole app can use.
final dataChangeNotifier = DataChangeNotifier();