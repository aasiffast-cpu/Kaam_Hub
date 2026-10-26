import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Custom 3-Layer Concentric Circular Rotating Loader.
/// Displays 3 distinct animated circular rings rotating at different speeds & directions
/// around the circular KaamHub brand logo.
class ThreeLayerCircularLoader extends StatefulWidget {
  final double size;
  final bool showLogo;
  final String? loadingText;
  final Color outerColor;
  final Color middleColor;
  final Color innerColor;

  const ThreeLayerCircularLoader({
    super.key,
    this.size = 140,
    this.showLogo = true,
    this.loadingText,
    this.outerColor = AppColors.primary,
    this.middleColor = AppColors.accent,
    this.innerColor = AppColors.primaryLight,
  });

  @override
  State<ThreeLayerCircularLoader> createState() =>
      _ThreeLayerCircularLoaderState();
}

class _ThreeLayerCircularLoaderState extends State<ThreeLayerCircularLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: s,
          height: s,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final val = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Layer 1: Outer Circular Ring (Clockwise, fast)
                  Transform.rotate(
                    angle: val * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(s, s),
                      painter: _ArcPainter(
                        color: widget.outerColor,
                        strokeWidth: 3.5,
                        sweepAngle: math.pi * 1.3,
                        startAngle: 0,
                      ),
                    ),
                  ),

                  // Layer 2: Middle Circular Ring (Counter-Clockwise, medium)
                  Transform.rotate(
                    angle: -val * 2 * math.pi * 1.5,
                    child: CustomPaint(
                      size: Size(s * 0.8, s * 0.8),
                      painter: _ArcPainter(
                        color: widget.middleColor,
                        strokeWidth: 3.0,
                        sweepAngle: math.pi * 1.1,
                        startAngle: math.pi * 0.4,
                      ),
                    ),
                  ),

                  // Layer 3: Inner Circular Ring (Clockwise, slow)
                  Transform.rotate(
                    angle: val * 2 * math.pi * 2.0,
                    child: CustomPaint(
                      size: Size(s * 0.62, s * 0.62),
                      painter: _ArcPainter(
                        color: widget.innerColor,
                        strokeWidth: 2.5,
                        sweepAngle: math.pi * 0.9,
                        startAngle: math.pi * 0.8,
                      ),
                    ),
                  ),

                  // Center: Circular KaamHub Logo
                  if (widget.showLogo)
                    Container(
                      width: s * 0.44,
                      height: s * 0.44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: widget.outerColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: widget.outerColor.withAlpha(40),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/kaamhub_logo_circular.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (widget.loadingText != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.loadingText!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Draw main arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Draw opposite secondary small arc for dual-rotating balance
    final secondaryPaint = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = strokeWidth * 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle + sweepAngle + 0.5,
      sweepAngle * 0.35,
      false,
      secondaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      startAngle != oldDelegate.startAngle ||
      sweepAngle != oldDelegate.sweepAngle;
}
