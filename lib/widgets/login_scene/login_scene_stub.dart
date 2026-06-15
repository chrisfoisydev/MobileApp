import 'package:flutter/material.dart';

/// Painted fallback for platforms without the three.js scene: a layered
/// Seattle vista — hazy Mount Rainier, the downtown skyline with the Space
/// Needle, an evergreen tree line and Puget Sound below.
class LoginScene extends StatelessWidget {
  const LoginScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF4F8), Color(0xFFDCEAEF), Color(0xFFEEF6F8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(painter: _SeattlePainter(), size: Size.infinite),
    );
  }
}

class _SeattlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.70;

    // Mount Rainier, hazy on the right.
    final mountain = Path()
      ..moveTo(w * 0.30, horizon)
      ..lineTo(w * 0.74, h * 0.30)
      ..lineTo(w * 1.18, horizon)
      ..close();
    canvas.drawPath(mountain, Paint()..color = const Color(0xFFAFC8D4));
    final snow = Path()
      ..moveTo(w * 0.655, h * 0.42)
      ..lineTo(w * 0.74, h * 0.30)
      ..lineTo(w * 0.825, h * 0.42)
      ..lineTo(w * 0.78, h * 0.445)
      ..lineTo(w * 0.72, h * 0.40)
      ..lineTo(w * 0.69, h * 0.45)
      ..close();
    canvas.drawPath(snow, Paint()..color = const Color(0xFFFBFDFF));

    // A softer peak low on the left.
    final peak = Path()
      ..moveTo(-w * 0.1, horizon)
      ..lineTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.5, horizon)
      ..close();
    canvas.drawPath(peak, Paint()..color = const Color(0xFFC4D6DE));

    // Downtown skyline.
    final tower = Paint()..color = const Color(0xFF4E6878);
    final towers = <List<double>>[
      [0.34, 0.55], [0.40, 0.50], [0.46, 0.46], [0.52, 0.58],
      [0.58, 0.52], [0.64, 0.57], [0.70, 0.61],
    ];
    for (final t in towers) {
      final cx = w * t[0];
      final top = h * t[1];
      canvas.drawRect(
        Rect.fromLTRB(cx - w * 0.022, top, cx + w * 0.022, horizon),
        tower,
      );
    }

    // Space Needle, left of downtown.
    final needle = Paint()..color = const Color(0xFF5E7886);
    final nx = w * 0.24;
    canvas.drawRect(
      Rect.fromLTRB(nx - w * 0.006, h * 0.50, nx + w * 0.006, horizon),
      needle,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(nx, h * 0.49), width: w * 0.07, height: h * 0.018),
      needle,
    );
    canvas.drawRect(
      Rect.fromLTRB(nx - w * 0.0015, h * 0.455, nx + w * 0.0015, h * 0.49),
      needle,
    );
    canvas.drawCircle(
        Offset(nx, h * 0.452), w * 0.008, Paint()..color = const Color(0xFFD62B2F));

    // Water band.
    canvas.drawRect(
      Rect.fromLTRB(0, horizon, w, h),
      Paint()..color = const Color(0xFF8FC4D6),
    );

    // Evergreen tree line along the shore.
    final fir = Paint()..color = const Color(0xFF2F6B4E);
    for (var i = 0; i < 9; i++) {
      final tx = w * (0.04 + i * 0.115);
      final th = h * (0.05 + (i.isEven ? 0.012 : 0.0));
      final treeBase = horizon + h * 0.006;
      final tree = Path()
        ..moveTo(tx, treeBase - th * 2.2)
        ..lineTo(tx - w * 0.03, treeBase)
        ..lineTo(tx + w * 0.03, treeBase)
        ..close();
      canvas.drawPath(tree, fir);
    }
  }

  @override
  bool shouldRepaint(covariant _SeattlePainter oldDelegate) => false;
}
