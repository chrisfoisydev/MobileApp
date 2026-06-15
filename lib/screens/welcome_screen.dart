import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import '../widgets/login_scene/login_scene.dart';
import 'account_summary_screen.dart';
import 'sign_in_screen.dart';

/// 0.0 Mobile screen door, redesigned light: an animated 3D scene
/// (three.js + GSAP on the web, painted fallback elsewhere) above a
/// rounded panel with the welcome copy and log-in entry points.
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
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-height 3D Seattle backdrop behind everything.
          const LoginScene(),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 306),
                  child: FadeTransition(
                    opacity: _entrance,
                    child: const _NcuaNotice(),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              // Scrim fades from the scene into solid white behind the
              // content so the backdrop reads full-height yet stays legible.
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.97),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.28, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _enter(0, _FloatingLogo(float: _float)),
                      const SizedBox(height: 20),
                      _enter(
                        1,
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: AppColors.navy,
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
                          style:
                              TextStyle(color: AppColors.slate, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _enter(
                        3,
                        SizedBox(
                          width: double.infinity,
                          height: 52,
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
                      const SizedBox(height: 12),
                      _enter(
                        4,
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AccountSummaryScreen(),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.teal, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Text(
                              'Log in with Biometrics',
                              style: TextStyle(
                                color: AppColors.teal,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            label: const _FaceIdIcon(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            color: AppColors.navy,
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
              color: AppColors.support,
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
          Icon(Icons.crop_free, color: AppColors.teal, size: 22),
          Icon(Icons.face, color: AppColors.teal, size: 12),
        ],
      ),
    );
  }
}
