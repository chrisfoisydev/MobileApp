import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/becu_logo.dart';
import 'account_summary_screen.dart';
import 'sign_in_screen.dart';

/// 0.0 Mobile screen door: dark photo backdrop, NCUA notice, welcome copy
/// and the biometric / standard log-in entry points.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DuskScenePainter()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 306),
                      child: const _NcuaNotice(),
                    ),
                  ),
                  const Spacer(),
                  const BecuLogo(height: 40),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 36 / 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'To your new destination online banking solution.',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
          ),
        ],
      ),
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
class _DuskScenePainter extends CustomPainter {
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

    final mountain = Path()
      ..moveTo(-w * 0.1, h * 0.58)
      ..lineTo(w * 0.32, h * 0.34)
      ..lineTo(w * 0.46, h * 0.40)
      ..lineTo(w * 0.62, h * 0.30)
      ..lineTo(w * 1.1, h * 0.60)
      ..close();
    canvas.drawPath(mountain, Paint()..color = const Color(0xFF565064));

    final trees = Paint()..color = const Color(0xFF1F2823);
    final treeBand = Path()..moveTo(0, h * 0.62);
    const step = 0.08;
    for (var x = 0.0; x < 1.0; x += step) {
      treeBand
        ..lineTo((x + step / 2) * w, h * 0.575)
        ..lineTo((x + step) * w, h * 0.62);
    }
    treeBand
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(treeBand, trees);

    canvas.drawRect(rect, Paint()..color = const Color(0xBF2B2B2B));
  }

  @override
  bool shouldRepaint(covariant _DuskScenePainter oldDelegate) => false;
}
