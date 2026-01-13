import 'package:flutter/material.dart';
import 'dart:math';

class AnalogClock extends StatelessWidget {
  final DateTime dateTime;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;

  const AnalogClock({
    super.key,
    required this.dateTime,
    this.hourHandColor = Colors.black,
    this.minuteHandColor = Colors.black,
    this.secondHandColor = Colors.red,
    this.numberColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AnalogClockPainter(
        dateTime: dateTime,
        hourHandColor: hourHandColor,
        minuteHandColor: minuteHandColor,
        secondHandColor: secondHandColor,
        numberColor: numberColor,
      ),
      size: const Size(300, 300),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color numberColor;

  _AnalogClockPainter({
    required this.dateTime,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.secondHandColor,
    required this.numberColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Draw clock border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw numbers
    _drawNumbers(canvas, center, radius);

    // Draw hour hand
    _drawHand(
      canvas,
      center,
      _calculateAngle(dateTime.hour % 12, 12),
      radius * 0.5,
      hourHandColor,
      8,
    );

    // Draw minute hand
    _drawHand(
      canvas,
      center,
      _calculateAngle(dateTime.minute, 60),
      radius * 0.7,
      minuteHandColor,
      6,
    );

    // Draw second hand
    _drawHand(
      canvas,
      center,
      _calculateAngle(dateTime.second, 60),
      radius * 0.8,
      secondHandColor,
      2,
    );

    // Draw center dot
    canvas.drawCircle(
      center,
      8,
      Paint()..color = Colors.black,
    );
  }

  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final x = center.dx + radius * 0.8 * cos(angle);
      final y = center.dy + radius * 0.8 * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(color: numberColor, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    Color color,
    double strokeWidth,
  ) {
    final x = center.dx + length * cos(angle);
    final y = center.dy + length * sin(angle);

    canvas.drawLine(
      center,
      Offset(x, y),
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  double _calculateAngle(int value, int max) {
    return (value * 360 / max - 90) * pi / 180;
  }

  @override
  bool shouldRepaint(_AnalogClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime;
  }
}
