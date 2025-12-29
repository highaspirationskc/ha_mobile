// lib/core/utils/platform_utils.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Get the platform string for API calls
/// Returns 'ios', 'android', or 'web'
String getPlatformString() {
  if (kIsWeb) {
    return 'web';
  }
  if (Platform.isIOS) {
    return 'ios';
  }
  if (Platform.isAndroid) {
    return 'android';
  }
  // Fallback for other platforms
  return 'unknown';
}
