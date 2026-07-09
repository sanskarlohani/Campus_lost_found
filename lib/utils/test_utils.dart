import 'package:flutter/foundation.dart';

class TestUtils {
  static bool get isTesting => kDebugMode && kIsWeb == false && 
      const bool.fromEnvironment('flutter.native_bridge', defaultValue: false) == false &&
      const bool.fromEnvironment('dart.library.io'); // heuristic for standard VM tests
  
  // A more reliable way to detect flutter test environment
  static bool isWidgetTest() {
    try {
      return (const bool.fromEnvironment('FLUTTER_TEST') || 
              !kIsWeb && const bool.fromEnvironment('dart.library.io'));
    } catch (_) {
      return false;
    }
  }
}
