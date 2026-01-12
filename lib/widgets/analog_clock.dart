
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClockPainter(DateTime.now()),
      child: Container(),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;

    // Neumorphic clock face
    final backgroundPaint = Paint()..color = const Color(0xFFE0E5EC);
    canvas.drawCircle(center, radius, backgroundPaint);

    final shadowPaint1 = Paint()
      // replaced deprecated withOpacity -> use Color.fromRGBO to set alpha precisely
      ..color = const Color.fromRGBO(255, 255, 255, 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(-5, -5), radius, shadowPaint1);

    final shadowPaint2 = Paint()
      // replaced deprecated withOpacity -> use Color.fromRGBO for precise alpha
      ..color = const Color.fromRGBO(0xA3, 0xB1, 0xC6, 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(5, 5), radius, shadowPaint2);

    // Clock face
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFE0E5EC)
          ..style = PaintingStyle.fill);

    // Inner shadow
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFC1C8D1), Color(0xFFFAFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 10));

    // Hour hand
    final hourHandPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final hourHandLength = radius * 0.5;
    final hourAngle =
        (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180;
    final hourHandPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + hourHandLength * sin(hourAngle),
          center.dy - hourHandLength * cos(hourAngle));
    canvas.drawShadow(hourHandPath, Colors.black, 4, true);
    canvas.drawPath(hourHandPath, hourHandPaint);

    // Minute hand
    final minuteHandPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final minuteHandLength = radius * 0.7;
    final minuteAngle =
        (dateTime.minute + dateTime.second / 60) * 6 * pi / 180;
    final minuteHandPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + minuteHandLength * sin(minuteAngle),
          center.dy - minuteHandLength * cos(minuteAngle));
    canvas.drawShadow(minuteHandPath, Colors.black, 3, true);
    canvas.drawPath(minuteHandPath, minuteHandPaint);

    // Second hand
    final secondHandPaint = Paint()
      ..color = Colors.red[400]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secondHandLength = radius * 0.9;
    final secondAngle = dateTime.second * 6 * pi / 180;
    final secondHandPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx + secondHandLength * sin(secondAngle),
          center.dy - secondHandLength * cos(secondAngle));
    canvas.drawShadow(secondHandPath, Colors.black, 2, true);
    canvas.drawPath(secondHandPath, secondHandPaint);

    // Center dot
    final centerDotPaint = Paint()..color = Colors.grey[700]!;
    canvas.drawCircle(center, 8, centerDotPaint);
    canvas.drawCircle(
        center,
        8,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFC1C8D1), Color(0xFFFAFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromCircle(center: center, radius: 8))
          ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
