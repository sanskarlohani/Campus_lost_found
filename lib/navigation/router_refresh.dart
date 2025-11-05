import 'dart:async';
import 'package:flutter/foundation.dart';

/// A ChangeNotifier that notifies GoRouter to refresh when the provided
/// stream emits (used to react to auth state changes).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      // Trigger a router refresh
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
