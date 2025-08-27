import 'package:flutter/foundation.dart';

class WebConfig {
  static void configure() {
    if (kIsWeb) {
      // Disable web debugging features that cause issues
      debugDefaultTargetPlatformOverride = null;
    }
  }
}
