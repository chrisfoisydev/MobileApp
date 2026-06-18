import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A fully-native, layered Seattle-dawn backdrop for the login screen.
///
/// Everything is drawn with [CustomPainter] and driven by Flutter's own
/// animation framework — no platform views or JavaScript. It composes
/// parallax mountain ranges, an alpenglow Mount Rainier, a twinkling
/// downtown skyline with the Space Needle, drifting fog, a shimmering
/// sound, and floating bokeh, with a staggered, eased entrance and a slow
/// ambient drift that also responds to pointer movement.
class LoginScene extends StatefulWidget {
  const LoginScene({super.key});

  @override
  State<LoginScene> createState() => _LoginSceneState();
}

class _LoginSceneState extends State<LoginScene>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();

  final ValueNotifier<Offset> _pointer = ValueNotifier(Offset.zero);

  late final List<_Window> _windows = _buildWindows();
  late final List<_Particle> _particles = _buildParticles();

  static List<_Window> _buildWindows() {
    final rng = math.Random(7);
    return List.generate(46, (_) {
      return _Window(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        phase: rng.nextDouble() * math.pi * 2,
        twinkle: rng.nextDouble() < 0.45,
      );
    });
  }

  static List<_Particle> _buildParticles() {
    final rng = math.Random(23);
    return List.generate(34, (_) {
      final depth = rng.nextDouble(); // 0 far .. 1 near
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 1.2 + depth * 3.2,
        depth: depth,
        speed: 0.15 + depth * 0.5,
        phase: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    _pointer.dispose();
    super.dispose();
  }

  void _updatePointer(Offset local, Size size) {
    if (size.isEmpty) return;
    _pointer.value = Offset(
      (local.dx / size.width - 0.5) * 2,
      (local.dy / size.height - 0.5) * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return MouseRegion(
          onHover: (e) => _updatePointer(e.localPosition, size),
          onExit: (_) => _pointer.value = Offset.zero,
          child: Listener(
            onPointerMove: (e) => _updatePointer(e.localPosition, size),
            child: AnimatedBuilder(
              animation: Listenable.merge([_entrance, _ambient, _pointer]),
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  isComplex: true,
                  painter: _ScenePainter(
                    entrance: _entrance.value,
                    ambient: _ambient.value,
                    pointer: _pointer.value,
                    windows: _windows,
                    particles: _particles,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Window {
  const _Window({
    required this.x,
    required this.y,
    required this.phase,
    required this.twinkle,
  });
  final double x;
  final double y;
  final double phase;
  final bool twinkle;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.depth,
    required this.speed,
    required this.phase,
  });
  final double x;
  final double y;
  final double radius;
  final double depth;
  final double speed;
  final double phase;
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.entrance,
    required this.ambient,
    required this.pointer,
    required this.windows,
    required this.particles,
  });

  final double entrance;
  final double ambient;
  final Offset pointer;
  final List<_Window> windows;
  final List<_Particle> particles;

  // Dawn palette.
  static const _skyTop = Color(0xFF4E6BA6);
  static const _skyUpper = Color(0xFF8893C2);
  static const _skyMauve = Color(0xFFC9B4CE);
  static const _skyHorizon = Color(0xFFF5D2AE);
  static const _peakFar = Color(0xFFB9C6DD);
  static const _rainier = Color(0xFF9DB2D2);

  /// Eased, staggered entrance progress for a layer.
  double _enter(double start, double end) {
    final t = ((entrance - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final ang = ambient * 2 * math.pi;
    final sway = math.sin(ang);
    final horizon = h * 0.66;

    _paintSky(canvas, size, horizon);
    _paintSun(canvas, size, horizon, ang);

    // Far Olympics range.
    final far = _enter(0.0, 0.5);
    _paintRange(
      canvas,
      size,
      baseline: horizon,
      peaks: const [0.0, 0.42, 0.18, 0.6, 0.32, 0.85],
      heightFactor: 0.16,
      color: _peakFar.withValues(alpha: 0.55 * far),
      dx: pointer.dx * 6 + sway * 4,
      dy: (1 - far) * 26,
    );

    _paintRainier(canvas, size, horizon, sway);

    _paintSkyline(canvas, size, horizon, ang, sway);

    _paintWater(canvas, size, horizon, ang);

    _paintTreeline(
      canvas,
      size,
      baseline: horizon + 2,
      height: h * 0.07,
      color: const Color(0xFF223A33),
      dx: pointer.dx * 22 + sway * 10,
      dy: (1 - _enter(0.4, 0.8)) * 34,
      step: 0.052,
      opacity: _enter(0.4, 0.8),
    );

    _paintFog(canvas, size, horizon, ang);
    _paintParticles(canvas, size, ang);
  }

  void _paintSky(Canvas canvas, Size size, double horizon) {
    final shift = math.sin(ambient * 2 * math.pi) * 0.015;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(_skyTop, _skyUpper, 0.1 + shift)!,
          _skyUpper,
          _skyMauve,
          _skyHorizon,
        ],
        stops: [0.0, 0.34, 0.52, (horizon / size.height).clamp(0.0, 1.0)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintSun(Canvas canvas, Size size, double horizon, double ang) {
    final intro = _enter(0.0, 0.7);
    // Sun rises a touch and breathes.
    final cx = size.width * (0.74 + pointer.dx * 0.02);
    final cy = horizon - size.height * (0.10 + 0.03 * intro) +
        math.sin(ang) * 4;
    final glowR = size.width * (0.5 + 0.02 * math.sin(ang));
    canvas.drawCircle(
      Offset(cx, cy),
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF1DC).withValues(alpha: 0.85 * intro),
            const Color(0xFFFFE2BE).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: glowR)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.05,
      Paint()..color = const Color(0xFFFFF6E8).withValues(alpha: 0.9 * intro),
    );
  }

  void _paintRange(
    Canvas canvas,
    Size size, {
    required double baseline,
    required List<double> peaks,
    required double heightFactor,
    required Color color,
    required double dx,
    required double dy,
  }) {
    final w = size.width;
    final h = size.height;
    final path = Path()..moveTo(-w * 0.2 + dx, baseline + dy);
    for (var i = 0; i < peaks.length; i++) {
      final x = (i / (peaks.length - 1)) * w * 1.4 - w * 0.2 + dx;
      final y = baseline + dy - h * heightFactor * peaks[i];
      path.lineTo(x, y);
    }
    path
      ..lineTo(w * 1.2 + dx, baseline + dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _paintRainier(Canvas canvas, Size size, double horizon, double sway) {
    final e = _enter(0.12, 0.6);
    if (e <= 0) return;
    final w = size.width;
    final h = size.height;
    final dx = pointer.dx * 12 + sway * 7;
    final dy = (1 - e) * 30;
    final cx = w * 0.34 + dx;
    final baseY = horizon + dy;
    final peakY = baseY - h * 0.42;
    final base = Path()
      ..moveTo(cx - w * 0.42, baseY)
      ..lineTo(cx, peakY)
      ..lineTo(cx + w * 0.42, baseY)
      ..close();
    canvas.drawPath(base, Paint()..color = _rainier.withValues(alpha: e));

    // Snow cap with a faint alpenglow tint.
    final snow = Path()
      ..moveTo(cx - w * 0.12, baseY - h * 0.30)
      ..lineTo(cx, peakY)
      ..lineTo(cx + w * 0.12, baseY - h * 0.30)
      ..lineTo(cx + w * 0.05, baseY - h * 0.265)
      ..lineTo(cx - w * 0.01, baseY - h * 0.30)
      ..lineTo(cx - w * 0.06, baseY - h * 0.27)
      ..close();
    canvas.drawPath(
      snow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFFFCEBE2).withValues(alpha: e),
            const Color(0xFFEAD3DA).withValues(alpha: e),
          ],
        ).createShader(Rect.fromLTWH(
            cx - w * 0.12, peakY, w * 0.24, h * 0.30)),
    );
  }

  void _paintSkyline(
      Canvas canvas, Size size, double horizon, double ang, double sway) {
    final e = _enter(0.22, 0.68);
    if (e <= 0) return;
    final w = size.width;
    final h = size.height;
    final dx = pointer.dx * 16 + sway * 9;
    final dy = (1 - e) * 26;
    final baseY = horizon + dy;
    final color = const Color(0xFF3B466A).withValues(alpha: e);

    canvas.save();
    canvas.translate(dx, 0);

    // Downtown towers.
    final towers = <List<double>>[
      [0.46, 0.10], [0.52, 0.15], [0.57, 0.21], [0.63, 0.13],
      [0.69, 0.18], [0.75, 0.11], [0.81, 0.16], [0.87, 0.09],
    ];
    for (final t in towers) {
      final cx = w * t[0];
      final th = h * t[1];
      final tw = w * 0.045;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - tw / 2, baseY - th, tw, th),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = color,
      );
    }

    // Space Needle.
    final nx = w * 0.30;
    final needleTop = baseY - h * 0.30;
    final paintN = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(nx - w * 0.007, needleTop, w * 0.014, h * 0.30),
        const Radius.circular(2),
      ),
      paintN,
    );
    canvas.drawPath(
      Path()
        ..moveTo(nx - w * 0.055, needleTop + h * 0.02)
        ..quadraticBezierTo(
            nx, needleTop - h * 0.02, nx + w * 0.055, needleTop + h * 0.02)
        ..lineTo(nx + w * 0.03, needleTop + h * 0.04)
        ..lineTo(nx - w * 0.03, needleTop + h * 0.04)
        ..close(),
      paintN,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(nx - w * 0.002, needleTop - h * 0.035, w * 0.004,
            h * 0.035),
        const Radius.circular(1),
      ),
      paintN,
    );
    // Beacon.
    final beacon = (0.5 + 0.5 * math.sin(ang * 3)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(nx, needleTop - h * 0.035),
      2.6,
      Paint()..color = const Color(0xFFFFC9C9).withValues(alpha: e * beacon),
    );

    // Twinkling windows over the towers.
    final wpaint = Paint();
    for (final win in windows) {
      final wx = w * (0.44 + win.x * 0.46);
      final wy = baseY - h * (0.02 + win.y * 0.17);
      if (wy > baseY - 4) continue;
      final tw = win.twinkle
          ? (0.45 + 0.55 * (0.5 + 0.5 * math.sin(ang * 2 + win.phase)))
          : 0.8;
      wpaint.color = const Color(0xFFFFD9A0).withValues(alpha: e * tw * 0.9);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(wx, wy), width: 2.2, height: 2.6),
        wpaint,
      );
    }
    canvas.restore();
  }

  void _paintWater(Canvas canvas, Size size, double horizon, double ang) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFFB7CCDD),
            Color(0xFF9FBBD2),
            Color(0xFF8CAAC6),
          ],
        ).createShader(rect),
    );
    // Shimmer bands.
    final shimmer = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (var i = 0; i < 6; i++) {
      final p = i / 6;
      final y = horizon + (h - horizon) * (0.08 + p * 0.8);
      final phase = math.sin(ang * 2 + i) * w * 0.04;
      final lw = w * (0.18 + 0.12 * (1 - p));
      final cx = w * (0.2 + p * 0.5) + phase;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, y), width: lw, height: 2),
          const Radius.circular(1),
        ),
        shimmer..color = Colors.white.withValues(alpha: 0.10 + 0.06 * (1 - p)),
      );
    }
  }

  void _paintTreeline(
    Canvas canvas,
    Size size, {
    required double baseline,
    required double height,
    required Color color,
    required double dx,
    required double dy,
    required double step,
    required double opacity,
  }) {
    if (opacity <= 0) return;
    final w = size.width;
    final path = Path()..moveTo(-w * 0.1 + dx, baseline + dy);
    for (var x = -0.1; x < 1.15; x += step) {
      final jitter = (math.sin(x * 53) * 0.5 + 0.5);
      path
        ..lineTo((x + step / 2) * w + dx, baseline + dy - height * (0.7 + jitter * 0.5))
        ..lineTo((x + step) * w + dx, baseline + dy);
    }
    path
      ..lineTo(w * 1.2 + dx, size.height)
      ..lineTo(-w * 0.1 + dx, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: opacity));
  }

  void _paintFog(Canvas canvas, Size size, double horizon, double ang) {
    final e = _enter(0.5, 0.95);
    if (e <= 0) return;
    final w = size.width;
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    for (var i = 0; i < 4; i++) {
      final drift = ((ambient * (0.3 + i * 0.12) + i * 0.27) % 1.0);
      final cx = (drift * 1.4 - 0.2) * w;
      final cy = horizon - size.height * (0.04 + i * 0.05);
      paint.color = Colors.white.withValues(alpha: (0.10 - i * 0.015) * e);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy), width: w * 0.5, height: size.height * 0.07),
        paint,
      );
    }
  }

  void _paintParticles(Canvas canvas, Size size, double ang) {
    final e = _enter(0.55, 1.0);
    if (e <= 0) return;
    final w = size.width;
    final h = size.height;
    for (final p in particles) {
      final drift = (p.y - ambient * p.speed) % 1.0;
      final y = drift * h;
      final x = p.x * w +
          math.sin(ang + p.phase) * (6 + p.depth * 14) +
          pointer.dx * (8 + p.depth * 26);
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(ang * 2 + p.phase));
      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()
          ..color = const Color(0xFFFFF4E2)
              .withValues(alpha: (0.10 + 0.30 * p.depth) * twinkle * e)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.entrance != entrance ||
      oldDelegate.ambient != ambient ||
      oldDelegate.pointer != pointer;
}
