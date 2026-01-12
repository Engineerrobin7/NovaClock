import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThreeDClock extends StatefulWidget {
  const ThreeDClock({super.key, this.size = 260});

  final double size;

  @override
  State<ThreeDClock> createState() => _ThreeDClockState();
}

class _ThreeDClockState extends State<ThreeDClock>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _sweepController;
  Offset _drag = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat(); // drives a smooth second-hand rotation
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _drag += d.delta / 100;
    });
  }

  void _onTap() {
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _sweepController]),
        builder: (context, child) {
          final now = DateTime.now();
          final second = now.second + now.millisecond / 1000.0;

          // Use small rotations for a 3D tilt effect driven by drag and subtle animation
          final tiltX = (_drag.dy).clamp(-0.6, 0.6);
          final tiltY = (-_drag.dx).clamp(-0.6, 0.6);

          final matrix = Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective
            ..rotateX(tiltX)
            ..rotateY(tiltY)
            ..rotateZ(0.0);

          return Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _ClockPainter(
                  second: second,
                  animationValue: _sweepController.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.second, required this.animationValue});

  final double second;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Background gradient
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [Color(0xFF2B2F4A), Color(0xFF12131A)],
        stops: [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.12)), bg);

    // Outer glow / rim
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..shader = SweepGradient(
        colors: [
          Colors.cyanAccent.withAlpha((0.6 * 255).round()),
          Colors.transparent,
        ],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.92, rim);

    // Face
  final face = Paint()..color = Colors.black.withAlpha((0.15 * 255).round());
    canvas.drawCircle(center, radius * 0.86, face);

    // Hour/minute ticks
    final tickPaint = Paint()
      ..color = Colors.white.withAlpha((0.85 * 255).round())
      ..strokeWidth = 2;
    for (int i = 0; i < 60; i++) {
      final isHour = i % 5 == 0;
      final len = isHour ? radius * 0.12 : radius * 0.06;
      final angle = (i / 60) * math.pi * 2;
      final p1 = Offset(
        center.dx + (radius * 0.7) * math.cos(angle),
        center.dy + (radius * 0.7) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius * 0.7 - len) * math.cos(angle),
        center.dy + (radius * 0.7 - len) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint..strokeWidth = isHour ? 3 : 1.2);
    }

    // Second hand
    final secondAngle = (second / 60) * 2 * math.pi - math.pi / 2;
    final secondPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secP = Offset(
      center.dx + (radius * 0.58) * math.cos(secondAngle),
      center.dy + (radius * 0.58) * math.sin(secondAngle),
    );
    canvas.drawLine(center, secP, secondPaint);

    // Center cap
    final cap = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.04, cap);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.second != second ||
        oldDelegate.animationValue != animationValue;
  }
}
