import 'dart:math' as math;
import 'package:flutter/material.dart';

class SunnyWidget extends StatefulWidget {
  const SunnyWidget({super.key});

  @override
  State<SunnyWidget> createState() => _SunnyWidgetState();
}

class _SunnyWidgetState extends State<SunnyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SunnyPainter(progress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class SunnyPainter extends CustomPainter {
  final double progress;

  SunnyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final sunCenter = Offset(size.width * 0.82, size.height * 0.16);

    // 1. Extra Brightness Shimmer Aura
    final pulse = (math.sin(progress * math.pi * 4) * 0.5 + 0.5);
    final auraRadius = 160.0 + pulse * 40.0;

    final auraPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          Colors.amberAccent.withValues(alpha: 0.45),
          Colors.yellowAccent.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: auraRadius));

    canvas.drawCircle(sunCenter, auraRadius, auraPaint);

    // 2. Rotating Solar Beams / Rays
    final rayCount = 14;
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.35 + pulse * 0.15),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final angleStep = (2 * math.pi) / rayCount;
    final rotationOffset = progress * 2 * math.pi;

    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);

    for (int i = 0; i < rayCount; i++) {
      final rayAngle = rotationOffset + (i * angleStep);
      final rayLength = 220.0 + (i % 2 == 0 ? 80.0 : 0.0) + pulse * 30.0;
      final rayWidth = 0.12 + (i % 3 == 0 ? 0.05 : 0.0);

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(
          math.cos(rayAngle - rayWidth) * rayLength,
          math.sin(rayAngle - rayWidth) * rayLength,
        )
        ..lineTo(
          math.cos(rayAngle + rayWidth) * rayLength,
          math.sin(rayAngle + rayWidth) * rayLength,
        )
        ..close();

      canvas.drawPath(path, rayPaint);
    }
    canvas.restore();

    // 3. Core Sun Disc with Glass Sheen
    final sunDiscPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.yellowAccent, Colors.amber],
        stops: const [0.2, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 45.0));

    canvas.drawCircle(sunCenter, 45.0, sunDiscPaint);

    // 4. Lens Flare Artifacts along diagonal line
    final flareAxis = Offset(-size.width * 0.6, size.height * 0.7);
    final flareCount = 4;
    for (int f = 1; f <= flareCount; f++) {
      final factor = f * 0.22;
      final flareCenter = Offset(
        sunCenter.dx + flareAxis.dx * factor,
        sunCenter.dy + flareAxis.dy * factor,
      );
      final flareSize = 12.0 + (f % 2 == 0 ? 18.0 : 6.0) + pulse * 4.0;
      final flarePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = (f % 2 == 0 ? Colors.cyanAccent : Colors.amberAccent)
            .withValues(alpha: 0.25 - (f * 0.04));

      canvas.drawCircle(flareCenter, flareSize, flarePaint);
    }

    // 5. Global Extra Brightness Gradient Overlay across app screen
    final globalBrightnessPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.amberAccent.withValues(alpha: 0.18 + pulse * 0.08),
          Colors.white.withValues(alpha: 0.08 + pulse * 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      globalBrightnessPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SunnyPainter oldDelegate) => true;
}
