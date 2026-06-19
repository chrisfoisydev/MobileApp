import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gsap/flutter_gsap.dart';

/// A cinematic "flying around Seattle" backdrop for the login screen.
///
/// Everything is drawn with [CustomPainter] and driven by Flutter's own
/// ticker — no platform views, no JavaScript, and no native plugins (so it
/// builds the same on web, Windows, and an Android emulator). The flight is
/// choreographed with `flutter_gsap` ([GTimeline] + [Gtween]): a GSAP-style
/// timeline banks the camera, lifts altitude, burns off the dawn haze and
/// raises the sun, while a continuously looping tween dollies the camera
/// forward so the parallax layers — clouds, the Olympics, Mount Rainier, the
/// downtown skyline and the Space Needle, Puget Sound, and foreground wisps —
/// streak past at depth-scaled speeds.
class LoginScene extends StatefulWidget {
  const LoginScene({super.key});

  @override
  State<LoginScene> createState() => _LoginSceneState();
}

class _LoginSceneState extends State<LoginScene>
    with TickerProviderStateMixin {
  // Continuous forward flight. Loops forever; its per-frame onUpdate is the
  // single repaint pulse for the whole scene.
  late final Gtween _flight = Gtween(
    vsync: this,
    duration: const Duration(seconds: 60),
    curve: GEase.none,
    repeat: -1,
    onUpdate: (_) => _frame.value++,
  );

  // GSAP-style entrance choreography. Built paused, then played once.
  late final GTimeline _intro = GTimeline(vsync: this, paused: true);
  late final Gtween _reveal;
  late final Gtween _lift;
  late final Gtween _bank;
  late final Gtween _sun;
  late final Gtween _haze;

  final ValueNotifier<int> _frame = ValueNotifier(0);
  final ValueNotifier<Offset> _pointer = ValueNotifier(Offset.zero);

  late final List<_Cloud> _clouds = _buildClouds();
  late final List<_Streak> _streaks = _buildStreaks();
  late final List<_Window> _windows = _buildWindows();

  @override
  void initState() {
    super.initState();

    Gtween phase(Duration d, Curve c) =>
        Gtween(vsync: this, duration: d, curve: c, paused: true);

    // The camera holds a beat, then climbs and banks into the city as the
    // dawn haze clears and the sun lifts off the horizon.
    _reveal = _intro.add(phase(const Duration(milliseconds: 1100), GEase.power2Out));
    _lift = _intro.add(phase(const Duration(milliseconds: 2600), GEase.expoOut),
        start: 0.15);
    _bank = _intro.add(
        phase(const Duration(milliseconds: 3200), GEase.power2InOut),
        start: 0.2);
    _sun = _intro.add(
        phase(const Duration(milliseconds: 2900), GEase.power2InOut),
        start: 0.35);
    _haze = _intro.add(phase(const Duration(milliseconds: 2400), GEase.power2Out),
        start: 0.6);

    _intro.play();
  }

  static List<_Cloud> _buildClouds() {
    final rng = math.Random(11);
    return List.generate(20, (_) {
      final depth = rng.nextDouble();
      return _Cloud(
        x: rng.nextDouble() * 1.4,
        y: 0.05 + rng.nextDouble() * 0.42,
        depth: depth,
        scale: 0.5 + depth * 1.3,
        puffs: 3 + rng.nextInt(3),
        seed: rng.nextInt(1 << 20),
      );
    });
  }

  static List<_Streak> _buildStreaks() {
    final rng = math.Random(29);
    return List.generate(26, (_) {
      final depth = 0.4 + rng.nextDouble() * 0.6; // foreground only
      return _Streak(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        depth: depth,
        length: 0.05 + depth * 0.14,
        phase: rng.nextDouble(),
      );
    });
  }

  static List<_Window> _buildWindows() {
    final rng = math.Random(7);
    return List.generate(54, (_) {
      return _Window(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        phase: rng.nextDouble() * math.pi * 2,
        twinkle: rng.nextDouble() < 0.5,
      );
    });
  }

  @override
  void dispose() {
    _flight.kill();
    _intro.kill();
    _frame.dispose();
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
              animation: Listenable.merge([_frame, _pointer]),
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  isComplex: true,
                  painter: _FlightPainter(
                    flight: _flight.progress,
                    reveal: _reveal.progress,
                    lift: _lift.progress,
                    bank: _bank.progress,
                    sun: _sun.progress,
                    haze: _haze.progress,
                    pointer: _pointer.value,
                    clouds: _clouds,
                    streaks: _streaks,
                    windows: _windows,
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

class _Cloud {
  const _Cloud({
    required this.x,
    required this.y,
    required this.depth,
    required this.scale,
    required this.puffs,
    required this.seed,
  });
  final double x;
  final double y;
  final double depth;
  final double scale;
  final int puffs;
  final int seed;
}

class _Streak {
  const _Streak({
    required this.x,
    required this.y,
    required this.depth,
    required this.length,
    required this.phase,
  });
  final double x;
  final double y;
  final double depth;
  final double length;
  final double phase;
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

class _FlightPainter extends CustomPainter {
  _FlightPainter({
    required this.flight,
    required this.reveal,
    required this.lift,
    required this.bank,
    required this.sun,
    required this.haze,
    required this.pointer,
    required this.clouds,
    required this.streaks,
    required this.windows,
  });

  final double flight;
  final double reveal;
  final double lift;
  final double bank;
  final double sun;
  final double haze;
  final Offset pointer;
  final List<_Cloud> clouds;
  final List<_Streak> streaks;
  final List<_Window> windows;

  // Dawn → early-morning palette.
  static const _skyTop = Color(0xFF3E5A97);
  static const _skyUpper = Color(0xFF7E8FC4);
  static const _skyMauve = Color(0xFFC9B2CE);
  static const _skyHorizon = Color(0xFFF7D6AC);
  static const _peakFar = Color(0xFFB9C6DD);
  static const _rainier = Color(0xFF9DB2D2);

  static double _wrap(double v) => v - v.floorToDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ang = flight * 2 * math.pi;

    // Camera framing: altitude lifts the horizon, the flight bobs gently, and
    // the banking turn rolls the whole frame a few degrees.
    final bob = math.sin(flight * 2 * math.pi * 3) * h * 0.006;
    final horizon = h * (0.70 - 0.05 * lift) + bob;
    final roll = (math.sin(bank * math.pi) * 0.5 + math.sin(ang) * 0.5) * 0.035 +
        pointer.dx * 0.012;

    canvas.save();
    // Roll + a hair of zoom so the rotated corners never expose the canvas.
    canvas.translate(w / 2, h / 2);
    canvas.rotate(roll);
    canvas.scale(1.10);
    canvas.translate(-w / 2, -h / 2 + bob * 2);

    _paintSky(canvas, size, horizon);
    _paintSun(canvas, size, horizon, ang);
    _paintClouds(canvas, size, horizon, far: true);
    _paintRange(canvas, size, horizon, ang);
    _paintRainier(canvas, size, horizon, ang);
    _paintSkyline(canvas, size, horizon, ang);
    _paintWater(canvas, size, horizon, ang);
    _paintClouds(canvas, size, horizon, far: false);
    _paintStreaks(canvas, size, ang);
    _paintHaze(canvas, size, horizon);

    canvas.restore();

    // Brief light wash that burns off as the scene reveals.
    final wash = (1 - reveal);
    if (wash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFFBEFE0).withValues(alpha: 0.9 * wash),
      );
    }
  }

  void _paintSky(Canvas canvas, Size size, double horizon) {
    final rect = Offset.zero & size;
    // Sky warms and brightens slightly as the sun rises.
    final top = Color.lerp(_skyTop, _skyUpper, 0.12 * sun)!;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, _skyUpper, _skyMauve, _skyHorizon],
          stops: [0.0, 0.32, 0.5, (horizon / size.height).clamp(0.0, 1.0)],
        ).createShader(rect),
    );
  }

  void _paintSun(Canvas canvas, Size size, double horizon, double ang) {
    final cx = size.width * (0.72 + pointer.dx * 0.02);
    // Climbs off the horizon as `sun` advances.
    final cy = horizon - size.height * (0.02 + 0.16 * sun) + math.sin(ang) * 3;
    final glowR = size.width * (0.55 + 0.02 * math.sin(ang));
    canvas.drawCircle(
      Offset(cx, cy),
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF3DD).withValues(alpha: 0.85 * sun),
            const Color(0xFFFFE2BE).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: glowR)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.052,
      Paint()..color = const Color(0xFFFFF7EA).withValues(alpha: 0.92 * sun),
    );
  }

  void _paintRange(Canvas canvas, Size size, double horizon, double ang) {
    final w = size.width;
    final h = size.height;
    // Far Olympics: slow parallax, drift slightly with the flight.
    final dx = -_wrap(flight * 0.12) * w * 0.4 + pointer.dx * 6;
    const peaks = [0.0, 0.42, 0.18, 0.6, 0.32, 0.85, 0.4, 0.7, 0.2, 0.55];
    final color = _peakFar.withValues(alpha: 0.5 * reveal);
    for (final tile in [0.0, w * 1.0]) {
      final path = Path()..moveTo(-w * 0.2 + dx + tile, horizon);
      for (var i = 0; i < peaks.length; i++) {
        final x = (i / (peaks.length - 1)) * w - w * 0.1 + dx + tile;
        final y = horizon - h * 0.15 * peaks[i];
        path.lineTo(x, y);
      }
      path
        ..lineTo(w * 1.1 + dx + tile, horizon)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  void _paintRainier(Canvas canvas, Size size, double horizon, double ang) {
    final e = reveal;
    if (e <= 0) return;
    final w = size.width;
    final h = size.height;
    // Medium-slow parallax: Rainier drifts grandly across the frame.
    final dx = (0.5 - _wrap(flight * 0.18 + 0.3)) * w * 1.6 + pointer.dx * 12;
    final cx = w * 0.5 + dx;
    final baseY = horizon;
    final peakY = baseY - h * 0.42;
    final base = Path()
      ..moveTo(cx - w * 0.42, baseY)
      ..lineTo(cx, peakY)
      ..lineTo(cx + w * 0.42, baseY)
      ..close();
    canvas.drawPath(base, Paint()..color = _rainier.withValues(alpha: e));

    // Snow cap with a faint alpenglow tint that warms with the sun.
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
            Color.lerp(const Color(0xFFEFE2EA), const Color(0xFFFCEBE2), sun)!
                .withValues(alpha: e),
            const Color(0xFFE0CCD6).withValues(alpha: e),
          ],
        ).createShader(
            Rect.fromLTWH(cx - w * 0.12, peakY, w * 0.24, h * 0.30)),
    );
  }

  void _paintSkyline(Canvas canvas, Size size, double horizon, double ang) {
    final e = reveal;
    if (e <= 0) return;
    final w = size.width;
    // Faster parallax than the mountains; the downtown cluster slides past and
    // wraps so the city keeps coming as we fly.
    final base = -_wrap(flight * 0.5) * w * 1.5 + pointer.dx * 16;
    for (final tile in [0.0, w * 1.5]) {
      _paintDowntown(canvas, size, horizon, ang, base + tile);
    }
  }

  void _paintDowntown(
      Canvas canvas, Size size, double horizon, double ang, double originX) {
    final w = size.width;
    final h = size.height;
    final color = const Color(0xFF374264).withValues(alpha: reveal);

    // Downtown towers.
    const towers = <List<double>>[
      [0.46, 0.10], [0.52, 0.16], [0.57, 0.22], [0.63, 0.13],
      [0.69, 0.19], [0.75, 0.11], [0.81, 0.17], [0.87, 0.09],
    ];
    for (final t in towers) {
      final cx = w * t[0] + originX;
      final th = h * t[1];
      const tw = 0.045;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - w * tw / 2, horizon - th, w * tw, th),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        Paint()..color = color,
      );
    }

    // Space Needle.
    final nx = w * 0.30 + originX;
    final needleTop = horizon - h * 0.30;
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
        Rect.fromLTWH(
            nx - w * 0.002, needleTop - h * 0.035, w * 0.004, h * 0.035),
        const Radius.circular(1),
      ),
      paintN,
    );
    final beacon = (0.5 + 0.5 * math.sin(ang * 6)).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(nx, needleTop - h * 0.035),
      2.8,
      Paint()
        ..color = const Color(0xFFFFC9C9).withValues(alpha: reveal * beacon),
    );

    // Twinkling windows across the towers.
    final wpaint = Paint();
    for (final win in windows) {
      final wx = w * 0.44 + win.x * w * 0.46 + originX;
      final wy = horizon - h * (0.02 + win.y * 0.18);
      if (wy > horizon - 4) continue;
      final tw = win.twinkle
          ? 0.45 + 0.55 * (0.5 + 0.5 * math.sin(ang * 4 + win.phase))
          : 0.82;
      wpaint.color =
          const Color(0xFFFFD9A0).withValues(alpha: reveal * tw * 0.9);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(wx, wy), width: 2.2, height: 2.6),
        wpaint,
      );
    }
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
            Color(0xFF9DB9D1),
            Color(0xFF7C9DBC),
          ],
        ).createShader(rect),
    );
    // Reflected warmth from the sun.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.55, horizon, w * 0.34, (h - horizon) * 0.7),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE6C4).withValues(alpha: 0.28 * sun),
            const Color(0xFFFFE6C4).withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromLTWH(w * 0.55, horizon, w * 0.34, (h - horizon) * 0.7)),
    );
    // Shimmer bands that race by faster nearer the camera (flight cue).
    for (var i = 0; i < 7; i++) {
      final p = i / 7;
      final y = horizon + (h - horizon) * (0.06 + p * 0.86);
      final speed = 0.3 + p * 1.6;
      final cx = _wrap(0.2 + p * 0.5 + flight * speed) * w * 1.4 - w * 0.2;
      final lw = w * (0.16 + 0.14 * p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, y), width: lw, height: 2),
          const Radius.circular(1),
        ),
        Paint()..color = Colors.white.withValues(alpha: (0.08 + 0.10 * p) * reveal),
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size, double horizon,
      {required bool far}) {
    final w = size.width;
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (final c in clouds) {
      final isFar = c.depth < 0.5;
      if (isFar != far) continue;
      // Speed scales with nearness → parallax depth.
      final speed = 0.1 + c.depth * 1.4;
      final x = (_wrap(c.x / 1.4 - flight * speed)) * w * 1.4 - w * 0.2;
      final y = c.y * (horizon * 0.92) + math.sin(flight * 6 + c.seed) * 3;
      final rng = math.Random(c.seed);
      final base = 22.0 * c.scale;
      final alpha = (far ? 0.12 : 0.18) * (0.5 + c.depth) * reveal;
      paint.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.35));
      for (var p = 0; p < c.puffs; p++) {
        final ox = (rng.nextDouble() - 0.5) * base * 2.4;
        final oy = (rng.nextDouble() - 0.5) * base * 0.7;
        final r = base * (0.6 + rng.nextDouble() * 0.7);
        canvas.drawCircle(Offset(x + ox, y + oy), r, paint);
      }
    }
  }

  void _paintStreaks(Canvas canvas, Size size, double ang) {
    if (reveal <= 0) return;
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    for (final s in streaks) {
      // Foreground wisps tear across fast and fan outward toward the edges,
      // selling the sense of speed past the camera.
      final speed = 0.8 + s.depth * 2.2;
      final t = _wrap(s.x + s.phase - flight * speed);
      final spread = (s.y - 0.5) * 2; // -1 top .. 1 bottom
      final x = t * w * 1.3 - w * 0.15;
      final y = s.y * h + math.sin(ang + s.phase * 6) * 4 + spread * 8;
      final len = w * s.length * (0.6 + 0.8 * t);
      paint
        ..strokeWidth = 1.0 + s.depth * 1.6
        ..color = Colors.white
            .withValues(alpha: (0.05 + 0.16 * s.depth) * reveal * (0.4 + t));
      canvas.drawLine(Offset(x, y), Offset(x + len, y + spread * 3), paint);
    }
  }

  void _paintHaze(Canvas canvas, Size size, double horizon) {
    // Morning haze along the horizon that burns off as `haze` advances.
    final amount = (1 - haze);
    if (amount <= 0.01) return;
    final w = size.width;
    final h = size.height;
    final band = Rect.fromLTWH(0, horizon - h * 0.12, w, h * 0.22);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.5 * amount),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(band)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(covariant _FlightPainter old) =>
      old.flight != flight ||
      old.reveal != reveal ||
      old.lift != lift ||
      old.bank != bank ||
      old.sun != sun ||
      old.haze != haze ||
      old.pointer != pointer;
}
