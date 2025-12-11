// Stub implementation for non-web platforms
import 'package:flutter/material.dart';

/// Register iframe view - no-op on mobile
void registerIframeView(String viewType, String url) {
  // No-op on mobile platforms - iframe not supported
}

/// Build iframe widget - returns null on mobile (use WebView instead)
Widget? buildIframeWidget(String viewType) {
  return null;
}

