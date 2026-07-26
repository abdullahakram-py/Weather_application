import 'dart:math' as math;
import 'package:flutter/material.dart';

class CloudItem {
  double xRatio;
  double yRatio;
  double scale;
  double speed;
  double opacity;
  List<Offset> puffOffsets;
  List<double> puffRadii;

  CloudItem({
    required this.xRatio,
    required this.yRatio,
    required this.scale,
    required this.speed,
    required this.opacity,
    required this.puffOffsets,
    required this.puffRadii,
  });
}

class CloudWidget extends StatefulWidget {
  final int cloudCount;

  const CloudWidget({super.key, this.cloudCount = 6});

  @override
  State<CloudWidget> createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CloudItem> _clouds = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initClouds();
    _controller.addListener(_updateCloudPositions);
  }

  void _initClouds() {
    _clouds.clear();
    for (int i = 0; i < widget.cloudCount; i++) {
      _clouds.add(
        _generateSingleCloud(
          initialX: _random.nextDouble() * 1.4 - 0.2,
          layer: i % 3,
        ),
      );
    }
  }

  CloudItem _generateSingleCloud({double? initialX, int layer = 0}) {
    final scale = 0.7 + (layer * 0.35) + _random.nextDouble() * 0.3;
    final speed = (0.0003 + (layer * 0.0004) + _random.nextDouble() * 0.0003);
    final opacity = 0.25 + (layer * 0.15) + _random.nextDouble() * 0.2;
    final yRatio = 0.05 + (layer * 0.12) + _random.nextDouble() * 0.15;

    // Generate puffs for cloud shape
    final puffCount = 5 + _random.nextInt(4);
    final puffOffsets = <Offset>[];
    final puffRadii = <double>[];

    for (int p = 0; p < puffCount; p++) {
      final offsetX = (p - puffCount / 2.0) * (20.0 * scale);
      final offsetY = _random.nextDouble() * -15.0 * scale;
      final radius = (25.0 + _random.nextDouble() * 20.0) * scale;
      puffOffsets.add(Offset(offsetX, offsetY));
      puffRadii.add(radius);
    }

    return CloudItem(
      xRatio: initialX ?? -0.4,
      yRatio: yRatio,
      scale: scale,
      speed: speed,
      opacity: opacity,
      puffOffsets: puffOffsets,
      puffRadii: puffRadii,
    );
  }

  void _updateCloudPositions() {
    for (var cloud in _clouds) {
      cloud.xRatio += cloud.speed;
      if (cloud.xRatio > 1.4) {
        cloud.xRatio = -0.4;
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
      painter: CloudPainter(clouds: _clouds),
      child: const SizedBox.expand(),
    );
  }
}

class CloudPainter extends CustomPainter {
  final List<CloudItem> clouds;

  CloudPainter({required this.clouds});

  @override
  void paint(Canvas canvas, Size size) {
    for (var cloud in clouds) {
      final center = Offset(
        cloud.xRatio * size.width,
        cloud.yRatio * size.height,
      );

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

      final Path cloudPath = Path();

      for (int i = 0; i < cloud.puffOffsets.length; i++) {
        final puffPos = center + cloud.puffOffsets[i];
        final radius = cloud.puffRadii[i];
        cloudPath.addOval(Rect.fromCircle(center: puffPos, radius: radius));
      }

      // Layered cloud lighting gradient
      final rect = cloudPath.getBounds();
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: (cloud.opacity * 1.2).clamp(0.0, 1.0)),
          Colors.lightBlueAccent.withValues(
            alpha: (cloud.opacity * 0.8).clamp(0.0, 1.0),
          ),
          Colors.blueGrey.withValues(
            alpha: (cloud.opacity * 0.4).clamp(0.0, 1.0),
          ),
        ],
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawPath(cloudPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CloudPainter oldDelegate) => true;
}
