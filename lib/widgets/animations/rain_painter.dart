import 'dart:math' as math;
import 'package:flutter/material.dart';

class RainDrop {
  double x;
  double y;
  double length;
  double speed;
  double opacity;
  double width;

  RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
    required this.width,
  });
}

class SplashRing {
  double x;
  double y;
  double radius;
  double maxRadius;
  double opacity;

  SplashRing({
    required this.x,
    required this.y,
    required this.radius,
    required this.maxRadius,
    required this.opacity,
  });
}

class RainWidget extends StatefulWidget {
  final int dropCount;
  final bool isHeavy;

  const RainWidget({super.key, this.dropCount = 70, this.isHeavy = false});

  @override
  State<RainWidget> createState() => _RainWidgetState();
}

class _RainWidgetState extends State<RainWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = [];
  final List<SplashRing> _splashes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updatePhysics);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_drops.isEmpty) {
      _initDrops();
    }
  }

  void _initDrops() {
    final count = widget.isHeavy
        ? (widget.dropCount * 1.5).round()
        : widget.dropCount;
    _drops.clear();
    for (int i = 0; i < count; i++) {
      _drops.add(
        RainDrop(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          length: 15 + _random.nextDouble() * 25,
          speed: (widget.isHeavy ? 1.2 : 0.8) + _random.nextDouble() * 0.6,
          opacity: 0.25 + _random.nextDouble() * 0.55,
          width: 1.0 + _random.nextDouble() * 1.5,
        ),
      );
    }
  }

  void _updatePhysics() {
    final size = MediaQuery.maybeOf(context)?.size ?? const Size(400, 800);
    final count = widget.isHeavy
        ? (widget.dropCount * 1.5).round()
        : widget.dropCount;

    if (_drops.length != count) {
      _initDrops();
    }

    for (var drop in _drops) {
      drop.y += drop.speed * 0.035;
      drop.x -= drop.speed * 0.008; // Slanted by wind

      if (drop.y > 1.0) {
        // Spawn a splash ring at bottom
        if (_random.nextDouble() < 0.4) {
          _splashes.add(
            SplashRing(
              x: drop.x * size.width,
              y: size.height * (0.85 + _random.nextDouble() * 0.12),
              radius: 1.0,
              maxRadius: 10.0 + _random.nextDouble() * 15.0,
              opacity: drop.opacity,
            ),
          );
        }

        // Reset drop to top
        drop.y = -0.1;
        drop.x = _random.nextDouble() * 1.2; // Extra x allowance for slant
      }
    }

    // Update splash rings
    for (int i = _splashes.length - 1; i >= 0; i--) {
      final splash = _splashes[i];
      splash.radius += 0.8;
      splash.opacity -= 0.04;
      if (splash.opacity <= 0 || splash.radius >= splash.maxRadius) {
        _splashes.removeAt(i);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainPainter(drops: _drops, splashes: _splashes),
      child: const SizedBox.expand(),
    );
  }
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final List<SplashRing> splashes;

  RainPainter({required this.drops, required this.splashes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double windAngleX = -12.0;

    // Draw rain drops
    for (var drop in drops) {
      final startX = drop.x * size.width;
      final startY = drop.y * size.height;

      paint
        ..color = Colors.white.withValues(alpha: drop.opacity)
        ..strokeWidth = drop.width;

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.lightBlueAccent.withValues(alpha: drop.opacity),
          Colors.white.withValues(alpha: drop.opacity),
        ],
      );

      final rect = Rect.fromLTWH(
        startX + windAngleX,
        startY,
        drop.width,
        drop.length,
      );
      paint.shader = gradient.createShader(rect);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + windAngleX, startY + drop.length),
        paint,
      );
    }

    // Draw splash rings at the bottom
    final splashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var splash in splashes) {
      splashPaint.color = Colors.lightBlueAccent.withValues(
        alpha: splash.opacity.clamp(0.0, 1.0),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(splash.x, splash.y),
          width: splash.radius * 2,
          height: splash.radius * 0.8,
        ),
        splashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainPainter oldDelegate) => true;
}
