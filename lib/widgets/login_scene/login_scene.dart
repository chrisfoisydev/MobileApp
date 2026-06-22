import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A layered, animated Seattle-dawn backdrop for the login screen.
///
/// The scene is composed as a [Stack] of depth-ordered layers — sky, sun,
/// the Olympics, Mount Rainier, the downtown skyline and Space Needle, Puget
/// Sound, drifting clouds, and floating bokeh — and every layer is
/// choreographed with `flutter_animate`: a staggered fade/slide/scale
/// entrance, then ambient loops (a breathing sun, parallax cloud drift,
/// twinkling lights, a pulsing beacon, and a shimmer across the water).
///
/// Pure Dart and plugin-free, so it renders identically on web, Windows, and
/// an Android emulator.
class LoginScene extends StatelessWidget {
  const LoginScene({super.key});

  /// Fraction of the height where the land/water horizon sits.
  static const double _horizon = 0.60;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _sky(),
              ..._stars(size),
              _sun(size),
              _silhouette(size, _RangePainter(),
                  delay: 300, slide: 0.10, dur: 1500),
              _silhouette(size, _RainierPainter(),
                  delay: 480, slide: 0.14, dur: 1500, drift: 5),
              ..._clouds(size, near: false),
              _silhouette(size, _SkylinePainter(),
                  delay: 680, slide: 0.16, dur: 1300, drift: 9),
              _beacon(size),
              _water(size),
              ..._clouds(size, near: true),
              ..._particles(size),
              _haze(size),
              const _Vignette(),
            ],
          ),
        );
      },
    );
  }

  // --- Sky -------------------------------------------------------------

  Widget _sky() {
    return Positioned.fill(
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF35508C),
              Color(0xFF6E7FB8),
              Color(0xFFC4AECC),
              Color(0xFFF7D6AC),
            ],
            stops: [0.0, 0.4, 0.58, 0.78],
          ),
        ),
      ).animate().fadeIn(duration: 800.ms),
    );
  }

  // --- Sun -------------------------------------------------------------

  Widget _sun(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.72;
    final cy = h * _horizon * 0.74;
    final glow = w * 1.05;
    final core = w * 0.13;
    final pivot = Alignment(cx / w * 2 - 1, cy / h * 2 - 1);

    final group = Stack(
      children: [
        Positioned(
          left: cx - glow / 2,
          top: cy - glow / 2,
          width: glow,
          height: glow,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xCCFFF1DC), Color(0x00FFE2BE)],
              ),
            ),
          ),
        ),
        Positioned(
          left: cx - core / 2,
          top: cy - core / 2,
          width: core,
          height: core,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, Color(0xFFFFE6BE)],
              ),
            ),
          ),
        ),
      ],
    );

    return Positioned.fill(
      child: group
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
              begin: 0.99,
              end: 1.05,
              duration: 5.seconds,
              curve: Curves.easeInOut,
              alignment: pivot)
          .animate()
          .fadeIn(delay: 200.ms, duration: 1600.ms)
          .scaleXY(
              begin: 0.7,
              end: 1.0,
              delay: 200.ms,
              duration: 1600.ms,
              curve: Curves.easeOutCubic,
              alignment: pivot)
          .moveY(begin: h * 0.05, end: 0, delay: 200.ms, duration: 1600.ms),
    );
  }

  // --- Painted silhouettes (range, Rainier, skyline) -------------------

  Widget _silhouette(
    Size size,
    CustomPainter painter, {
    required int delay,
    required double slide,
    required int dur,
    double drift = 3,
  }) {
    return Positioned.fill(
      child: CustomPaint(painter: painter)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(
              begin: -drift,
              end: drift,
              duration: (16 + drift).seconds,
              curve: Curves.easeInOut)
          .animate()
          .fadeIn(delay: delay.ms, duration: dur.ms)
          .slideY(
              begin: slide,
              end: 0,
              delay: delay.ms,
              duration: dur.ms,
              curve: Curves.easeOutCubic),
    );
  }

  // --- Space Needle beacon --------------------------------------------

  Widget _beacon(Size size) {
    final w = size.width;
    final h = size.height;
    final nx = w * 0.30;
    final ny = (h * _horizon) - h * 0.335;
    return Positioned(
      left: nx - 5,
      top: ny - 5,
      width: 10,
      height: 10,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFD0CF),
          boxShadow: [
            BoxShadow(color: Color(0x88FF8A8A), blurRadius: 10, spreadRadius: 2),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fade(begin: 0.25, end: 1.0, duration: 1300.ms, curve: Curves.easeInOut)
          .scaleXY(begin: 0.7, end: 1.15, duration: 1300.ms)
          .animate()
          .fadeIn(delay: 900.ms, duration: 800.ms),
    );
  }

  // --- Water -----------------------------------------------------------

  Widget _water(Size size) {
    return Positioned.fill(
      child: CustomPaint(painter: _WaterPainter(horizon: _horizon))
          .animate()
          .fadeIn(delay: 760.ms, duration: 1200.ms),
    );
  }

  // --- Haze + vignette -------------------------------------------------

  Widget _haze(Size size) {
    return Positioned.fill(
      child: CustomPaint(painter: _HazePainter(horizon: _horizon))
          .animate()
          .fadeIn(delay: 700.ms, duration: 1600.ms),
    );
  }

  // --- Stars -----------------------------------------------------------

  List<Widget> _stars(Size size) {
    final rng = math.Random(5);
    return List.generate(6, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.34;
      final s = 1.5 + rng.nextDouble() * 1.8;
      final dur = (1400 + rng.nextInt(1800)).ms;
      return Positioned(
        left: x,
        top: y,
        width: s,
        height: s,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(begin: 0.15, end: 0.8, duration: dur, curve: Curves.easeInOut)
            .animate()
            .fadeIn(delay: (400 + i * 60).ms, duration: 1200.ms),
      );
    });
  }

  // --- Clouds ----------------------------------------------------------

  List<Widget> _clouds(Size size, {required bool near}) {
    final w = size.width;
    final h = size.height;
    final rng = math.Random(near ? 41 : 17);
    final count = 2; // fewer for software-rendered GPUs
    return List.generate(count, (i) {
      final depth = near ? 0.7 + rng.nextDouble() * 0.3 : rng.nextDouble() * 0.4;
      final cw = w * (near ? 0.5 : 0.34) * (0.7 + depth);
      final ch = cw * 0.42;
      final y = (near ? h * 0.40 : h * 0.10) +
          rng.nextDouble() * (near ? h * 0.16 : h * 0.20);
      final startX = rng.nextDouble() * (w + cw) - cw / 2;
      final travel = (near ? 70.0 : 36.0) * (0.6 + depth);
      final dur = (near ? 26 : 44).seconds;
      final alpha = near ? 0.22 : 0.14;
      return Positioned(
        left: startX,
        top: y,
        width: cw,
        height: ch,
        child: CustomPaint(painter: _CloudPainter(alpha: alpha, seed: i * 7 + 3))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveX(
                begin: -travel,
                end: travel,
                duration: dur,
                curve: Curves.easeInOut)
            .animate()
            .fadeIn(delay: (850 + i * 120).ms, duration: 1600.ms),
      );
    });
  }

  // --- Floating bokeh particles ---------------------------------------

  List<Widget> _particles(Size size) {
    final w = size.width;
    final h = size.height;
    final rng = math.Random(23);
    return List.generate(8, (i) {
      final depth = rng.nextDouble();
      final s = 3.0 + depth * 9.0;
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.92;
      final drift = 14 + depth * 30;
      final dur = (3200 + rng.nextInt(3600)).ms;
      final warm = rng.nextBool();
      final color = warm ? const Color(0xFFFFE8C6) : const Color(0xFFDCEBFF);
      return Positioned(
        left: x,
        top: y,
        width: s,
        height: s,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0.0)],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
                begin: drift / 2,
                end: -drift,
                duration: dur,
                curve: Curves.easeInOut)
            .moveX(
                begin: -drift * 0.3,
                end: drift * 0.3,
                duration: dur,
                curve: Curves.easeInOut)
            .fade(
                begin: 0.15 + depth * 0.2,
                end: 0.4 + depth * 0.5,
                duration: dur)
            .scaleXY(begin: 0.85, end: 1.15, duration: dur)
            .animate()
            .fadeIn(delay: (1000 + i * 70).ms, duration: 1400.ms),
      );
    });
  }
}

/// Foreground darkening so the login form sits on a richer base.
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.1,
              colors: [Color(0x00000000), Color(0x2A0A1430)],
              stops: [0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _RangePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h * LoginScene._horizon;
    const peaks = [0.0, 0.45, 0.2, 0.62, 0.34, 0.85, 0.4, 0.72, 0.22, 0.55];
    final path = Path()..moveTo(-w * 0.15, base);
    for (var i = 0; i < peaks.length; i++) {
      final x = (i / (peaks.length - 1)) * w * 1.2 - w * 0.1;
      path.lineTo(x, base - h * 0.16 * peaks[i]);
    }
    path
      ..lineTo(w * 1.15, base)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC2CFE4), Color(0xFF9FB1CF)],
        ).createShader(Rect.fromLTWH(0, base - h * 0.16, w, h * 0.16))
        ..color = const Color(0xFFB9C6DD),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RainierPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h * LoginScene._horizon;
    final cx = w * 0.5;
    final peakY = base - h * 0.42;

    final body = Path()
      ..moveTo(cx - w * 0.44, base)
      ..lineTo(cx, peakY)
      ..lineTo(cx + w * 0.44, base)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9BCD9), Color(0xFF8AA0C4)],
        ).createShader(Rect.fromLTWH(cx - w * 0.44, peakY, w * 0.88, h * 0.42)),
    );

    // Alpenglow snow cap.
    final snow = Path()
      ..moveTo(cx - w * 0.13, base - h * 0.30)
      ..lineTo(cx, peakY)
      ..lineTo(cx + w * 0.13, base - h * 0.30)
      ..lineTo(cx + w * 0.05, base - h * 0.265)
      ..lineTo(cx - w * 0.01, base - h * 0.30)
      ..lineTo(cx - w * 0.06, base - h * 0.27)
      ..close();
    canvas.drawPath(
      snow,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFDEEE6), Color(0xFFEAD4DC)],
        ).createShader(
            Rect.fromLTWH(cx - w * 0.13, peakY, w * 0.26, h * 0.30)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = h * LoginScene._horizon;
    final fill = Paint()..color = const Color(0xFF2C3656);

    const towers = <List<double>>[
      [0.46, 0.10], [0.52, 0.16], [0.57, 0.22], [0.63, 0.13],
      [0.69, 0.19], [0.75, 0.11], [0.81, 0.17], [0.87, 0.09],
    ];
    for (final t in towers) {
      final cx = w * t[0];
      final th = h * t[1];
      const tw = 0.045;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - w * tw / 2, base - th, w * tw, th),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        fill,
      );
    }

    // Space Needle.
    final nx = w * 0.30;
    final needleTop = base - h * 0.30;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(nx - w * 0.007, needleTop, w * 0.014, h * 0.30),
        const Radius.circular(2),
      ),
      fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(nx - w * 0.055, needleTop + h * 0.02)
        ..quadraticBezierTo(
            nx, needleTop - h * 0.02, nx + w * 0.055, needleTop + h * 0.02)
        ..lineTo(nx + w * 0.03, needleTop + h * 0.04)
        ..lineTo(nx - w * 0.03, needleTop + h * 0.04)
        ..close(),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(nx - w * 0.002, needleTop - h * 0.035, w * 0.004,
            h * 0.035),
        const Radius.circular(1),
      ),
      fill,
    );

    // Warm windows.
    final rng = math.Random(7);
    final wpaint = Paint();
    for (var i = 0; i < 60; i++) {
      final wx = w * (0.44 + rng.nextDouble() * 0.46);
      final wy = base - h * (0.02 + rng.nextDouble() * 0.17);
      wpaint.color =
          const Color(0xFFFFD79C).withValues(alpha: 0.5 + rng.nextDouble() * 0.4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(wx, wy), width: 2.0, height: 2.4),
        wpaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaterPainter extends CustomPainter {
  _WaterPainter({required this.horizon});
  final double horizon;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final top = h * horizon;
    final rect = Rect.fromLTWH(0, top, w, h - top);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB7CCDD), Color(0xFF9DB9D1), Color(0xFF6F92B4)],
        ).createShader(rect),
    );
    // Warm reflection beneath the sun.
    final refl = Rect.fromLTWH(w * 0.56, top, w * 0.32, (h - top) * 0.75);
    canvas.drawRect(
      refl,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE6C4).withValues(alpha: 0.32),
            const Color(0xFFFFE6C4).withValues(alpha: 0.0),
          ],
        ).createShader(refl),
    );
  }

  @override
  bool shouldRepaint(covariant _WaterPainter oldDelegate) => false;
}

class _HazePainter extends CustomPainter {
  _HazePainter({required this.horizon});
  final double horizon;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final band = Rect.fromLTWH(0, h * horizon - h * 0.10, w, h * 0.20);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.34),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(covariant _HazePainter oldDelegate) => false;
}

class _CloudPainter extends CustomPainter {
  _CloudPainter({required this.alpha, required this.seed});
  final double alpha;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final cy = size.height * 0.6;
    final puffs = 4 + rng.nextInt(3);
    for (var i = 0; i < puffs; i++) {
      final px = size.width * (0.12 + 0.76 * (i / (puffs - 1)));
      final py = cy + (rng.nextDouble() - 0.5) * size.height * 0.4;
      final r = size.height * (0.45 + rng.nextDouble() * 0.5);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: r));
      canvas.drawCircle(Offset(px, py), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => false;
}
