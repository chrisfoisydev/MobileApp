import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import 'account_summary_screen.dart';
import 'sign_in_screen.dart';

/// 0.0 Mobile screen door: dark photo backdrop, NCUA notice, welcome copy
/// and the biometric / standard log-in entry points. The backdrop drifts
/// with a slow parallax, the logo floats with a 3D perspective tilt, and
/// the content staggers in on launch.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  /// Staggers [child] in: each slot fades and slides up slightly later
  /// than the previous one.
  Widget _enter(int slot, Widget child) {
    final start = (slot * 0.13).clamp(0.0, 0.5);
    final t = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, start + 0.5, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: t,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.35), end: Offset.zero).animate(t),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DuskScenePainter(drift: _float)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _entrance,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 306),
                        child: const _NcuaNotice(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _enter(0, _FloatingLogo(float: _float)),
                  const SizedBox(height: 16),
                  _enter(
                    1,
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 36 / 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _enter(
                    2,
                    const Text(
                      'To your new destination online banking solution.',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _enter(
                    3,
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AccountSummaryScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Text(
                          'Log in with Biometrics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        label: const _FaceIdIcon(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _enter(
                    4,
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.becuRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The BECU lockup floating with a gentle 3D perspective tilt.
class _FloatingLogo extends StatelessWidget {
  const _FloatingLogo({required this.float});

  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: float,
      builder: (context, child) {
        // Triangle wave 0..1..0 eased into a smooth sway.
        final t = Curves.easeInOut.transform(float.value);
        final angleY = (t - 0.5) * 0.5;
        final angleX = math.sin(t * math.pi) * 0.06;
        final lift = (t - 0.5) * -6;
        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..translateByDouble(0, lift, 0, 1)
            ..rotateY(angleY)
            ..rotateX(angleX),
          child: child,
        );
      },
      child: const BecuLogo(height: 40),
    );
  }
}

class _NcuaNotice extends StatelessWidget {
  const _NcuaNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NCUA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 24 / 17,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'NCUA-insured - Backed by the full faith and credit of the '
            'U.S. Government',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 16 / 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _FaceIdIcon extends StatelessWidget {
  const _FaceIdIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.crop_free, color: Colors.white, size: 22),
          Icon(Icons.face, color: Colors.white, size: 12),
        ],
      ),
    );
  }
}

/// Stand-in for the Mount Rainier photo in the design: a muted dusk
/// gradient with mountain and tree-line silhouettes under a dark scrim.
/// [drift] slowly shifts the layers for a subtle parallax.
class _DuskScenePainter extends CustomPainter {
  _DuskScenePainter({required this.drift}) : super(repaint: drift);

  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3A3340),
          Color(0xFF5C4450),
          Color(0xFF2C3331),
          Color(0xFF1E2421),
        ],
        stops: [0.0, 0.42, 0.62, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, sky);

    final w = size.width;
    final h = size.height;
    final t = Curves.easeInOut.transform(drift.value) - 0.5;

    final mountainShift = t * 10;
    final mountain = Path()
      ..moveTo(-w * 0.1 + mountainShift, h * 0.58)
      ..lineTo(w * 0.32 + mountainShift, h * 0.34)
      ..lineTo(w * 0.46 + mountainShift, h * 0.40)
      ..lineTo(w * 0.62 + mountainShift, h * 0.30)
      ..lineTo(w * 1.1 + mountainShift, h * 0.60)
      ..close();
    canvas.drawPath(mountain, Paint()..color = const Color(0xFF565064));

    final treeShift = t * -16;
    final trees = Paint()..color = const Color(0xFF1F2823);
    final treeBand = Path()..moveTo(-w * 0.1 + treeShift, h * 0.62);
    const step = 0.08;
    for (var x = -0.1; x < 1.1; x += step) {
      treeBand
        ..lineTo((x + step / 2) * w + treeShift, h * 0.575)
        ..lineTo((x + step) * w + treeShift, h * 0.62);
    }
    treeBand
      ..lineTo(w * 1.2 + treeShift, h)
      ..lineTo(-w * 0.1 + treeShift, h)
      ..close();
    canvas.drawPath(treeBand, trees);

    canvas.drawRect(rect, Paint()..color = const Color(0xBF2B2B2B));
  }

  @override
  bool shouldRepaint(covariant _DuskScenePainter oldDelegate) => false;
}
