import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final List<Color>? gradientColors;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.20,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.onTap,
    this.borderColor,
    this.gradientColors,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        widget.borderColor ?? Colors.white.withValues(alpha: 0.32);

    final List<Color> bgGradient =
        widget.gradientColors ??
        [
          Colors.white.withValues(alpha: widget.opacity + 0.10),
          Colors.white.withValues(alpha: widget.opacity),
          Colors.white.withValues(alpha: widget.opacity * 0.5),
        ];

    return Container(
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onTap != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  padding: widget.padding,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: bgGradient,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                      color: _isHovered
                          ? Colors.white.withValues(alpha: 0.55)
                          : effectiveBorderColor,
                      width: _isHovered ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: -2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.20),
                        blurRadius: 8,
                        spreadRadius: -1,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Glossy Top Sheen Highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.6),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
