// Web-specific implementation for iframe embeds
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// Register iframe view for Flutter Web
void registerIframeView(String viewType, String url) {
  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow =
          'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
      ..allowFullscreen = true;
    return iframe;
  });
}

/// Build iframe widget for web
Widget? buildIframeWidget(String viewType) {
  return HtmlElementView(viewType: viewType);
}

