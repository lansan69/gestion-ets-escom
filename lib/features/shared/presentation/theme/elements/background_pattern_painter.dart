// ============================================================
// NOMBRE: background_pattern_painter.dart
// USO: CustomPainter que dibuja el fondo decorativo azul con
//      círculos y puntos. Consumido por AppShell, WelcomePage
//      y las pantallas de onboarding.
// ============================================================
import 'package:flutter/material.dart';

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 70, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.25), 110, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 55, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 85, circlePaint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
