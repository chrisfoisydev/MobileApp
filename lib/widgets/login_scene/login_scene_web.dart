import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

@JS('initLoginScene')
external void _initLoginScene(web.HTMLElement element);

bool _factoryRegistered = false;

/// Embeds the three.js + GSAP scene defined in web/login_scene.js.
class LoginScene extends StatelessWidget {
  const LoginScene({super.key});

  @override
  Widget build(BuildContext context) {
    if (!_factoryRegistered) {
      _factoryRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory('login-scene',
          (int viewId) {
        final element = web.HTMLDivElement()
          ..style.width = '100%'
          ..style.height = '100%';
        // The scene script polls until the element has a size, so it is
        // safe to kick it off before the element is attached.
        _initLoginScene(element);
        return element;
      });
    }
    return const HtmlElementView(viewType: 'login-scene');
  }
}
