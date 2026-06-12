/// The animated 3D backdrop for the login screen.
///
/// On the web this embeds a three.js + GSAP scene (see web/login_scene.js);
/// elsewhere it falls back to a Flutter-painted backdrop.
library;

export 'login_scene_stub.dart'
    if (dart.library.js_interop) 'login_scene_web.dart';
