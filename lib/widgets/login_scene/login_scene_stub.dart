import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Painted fallback for platforms without the three.js scene: the same
/// light gradient with soft out-of-focus shapes in BECU colors.
class LoginScene extends StatelessWidget {
  const LoginScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7FAFC), Color(0xFFE3EFF2), Color(0xFFF2F7F9)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: CustomPaint(painter: _SoftShapesPainter(), size: Size.infinite),
    );
  }
}

class _SoftShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void blob(double x, double y, double r, Color color, double opacity) {
      canvas.drawCircle(
        Offset(w * x, h * y),
        r,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    blob(0.5, 0.45, w * 0.18, AppColors.becuRed, 0.85);
    blob(0.16, 0.25, w * 0.10, AppColors.teal, 0.7);
    blob(0.85, 0.22, w * 0.07, const Color(0xFF14304A), 0.6);
    blob(0.13, 0.68, w * 0.06, Colors.white, 0.9);
    blob(0.86, 0.62, w * 0.05, AppColors.teal, 0.6);
    blob(0.72, 0.78, w * 0.035, AppColors.becuRed, 0.5);
  }

  @override
  bool shouldRepaint(covariant _SoftShapesPainter oldDelegate) => false;
}
