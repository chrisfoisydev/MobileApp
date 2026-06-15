import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A faux iOS status bar (clock plus cellular / Wi-Fi / battery glyphs),
/// matching the device frame in the Figma designs. Purely decorative.
class IOSStatusBar extends StatelessWidget {
  const IOSStatusBar({
    super.key,
    this.height = 44,
    this.time = '9:41',
    this.color = AppColors.navy,
  });

  final double height;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // The bar is overlaid outside any Material, so inherit the app's font
    // family from the theme rather than the framework fallback.
    final clockStyle = (Theme.of(context).textTheme.bodyMedium ??
            const TextStyle())
        .copyWith(
      color: color,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time, style: clockStyle),
            Row(
              children: [
                CustomPaint(size: const Size(17, 11), painter: _CellularPainter(color)),
                const SizedBox(width: 5),
                CustomPaint(size: const Size(16, 11), painter: _WifiPainter(color)),
                const SizedBox(width: 5),
                CustomPaint(size: const Size(25, 12), painter: _BatteryPainter(color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps every route with the simulated device top inset and overlays the
/// status bar. Use as [MaterialApp.builder].
Widget deviceFrameBuilder(BuildContext context, Widget? child) {
  final mq = MediaQuery.of(context);
  const barHeight = 44.0;
  return MediaQuery(
    data: mq.copyWith(
      padding: mq.padding.copyWith(top: barHeight),
      viewPadding: mq.viewPadding.copyWith(top: barHeight),
    ),
    child: Stack(
      children: [
        if (child != null) child,
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(child: IOSStatusBar()),
        ),
      ],
    ),
  );
}

class _CellularPainter extends CustomPainter {
  _CellularPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const bars = 4;
    const heights = [0.42, 0.62, 0.81, 1.0];
    final barW = (size.width - (bars - 1) * 2) / bars;
    for (var i = 0; i < bars; i++) {
      final h = size.height * heights[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (barW + 2), size.height - h, barW, h),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CellularPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WifiPainter extends CustomPainter {
  _WifiPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height * 0.92);
    for (var i = 0; i < 3; i++) {
      paint.strokeWidth = 1.6;
      final r = size.width * (0.2 + i * 0.24);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        3.927, // 225°
        1.4288, // ~81.8° sweep, centered upward
        false,
        paint,
      );
    }
    canvas.drawCircle(center, 1.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WifiPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BatteryPainter extends CustomPainter {
  _BatteryPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyW = size.width - 3;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bodyW, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Positive terminal nub.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyW + 0.6, size.height * 0.3, 2, size.height * 0.4),
        const Radius.circular(1),
      ),
      Paint()..color = color.withValues(alpha: 0.4),
    );
    // Charge level.
    const inset = 2.0;
    final fillW = (bodyW - inset * 2) * 0.82;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(inset, inset, fillW, size.height - inset * 2),
        const Radius.circular(1.5),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryPainter oldDelegate) =>
      oldDelegate.color != color;
}
