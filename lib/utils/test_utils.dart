import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class TestUtils {
  /// Reliable way to detect if we are running in a 'flutter test' environment.
  /// Works across all platforms including Web.
  static bool isWidgetTest() {
    if (kIsWeb) {
      return const bool.fromEnvironment('FLUTTER_TEST');
    }
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }
}
