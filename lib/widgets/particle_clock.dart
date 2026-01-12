import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleClock extends StatefulWidget {
  final double size;
  const ParticleClock({super.key, this.size = 300});

  @override
  State<ParticleClock> createState() => _ParticleClockState();
}

class _ParticleClockState extends State<ParticleClock> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize particles
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle(_random));
    }
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _ParticleClockPainter(
              particles: _particles,
              time: DateTime.now(),
              animationValue: _controller.value,
              primaryColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double angle;
  double radius;
  double speed;
  double opacity;

  Particle(math.Random random)
      : angle = random.nextDouble() * 2 * math.pi,
        radius = random.nextDouble(),
        speed = 0.002 + random.nextDouble() * 0.005,
        opacity = 0.3 + random.nextDouble() * 0.7;

  void update() {
    angle += speed;
    if (angle > 2 * math.pi) angle -= 2 * math.pi;
  }
}

class _ParticleClockPainter extends CustomPainter {
  final List<Particle> particles;
  final DateTime time;
  final double animationValue;
  final Color primaryColor;

  _ParticleClockPainter({
    required this.particles,
    required this.time,
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // 1. Draw Outer Glow Ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          primaryColor.withOpacity(0.0),
          primaryColor.withOpacity(0.5),
          primaryColor,
        ],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, glowPaint);

    // 2. Draw Particles (Orbiting Stars)
    final particlePaint = Paint()..color = Colors.white;
    for (var particle in particles) {
      particle.update();
      final pRadius = radius * (0.5 + 0.4 * particle.radius);
      final x = center.dx + pRadius * math.cos(particle.angle);
      final y = center.dy + pRadius * math.sin(particle.angle);
      
      particlePaint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(x, y), 1.5, particlePaint);
    }

    // 3. Draw Time Indicators (Neon Ticks)
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final isHour = i % 5 == 0;
      final length = isHour ? 15.0 : 5.0;
      
      tickPaint.color = isHour 
          ? primaryColor 
          : Colors.white.withOpacity(0.3);
      
      final p1 = Offset(
        center.dx + (radius - 20) * math.cos(angle),
        center.dy + (radius - 20) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 20 - length) * math.cos(angle),
        center.dy + (radius - 20 - length) * math.sin(angle),
      );
      
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. Draw Hands (Modern & Sleek)
    _drawHand(canvas, center, (time.hour % 12 + time.minute / 60) * 30, radius * 0.5, 6, Colors.white);
    _drawHand(canvas, center, (time.minute + time.second / 60) * 6, radius * 0.7, 4, primaryColor.withOpacity(0.8));
    _drawHand(canvas, center, (time.second + time.millisecond / 1000) * 6, radius * 0.8, 2, Colors.redAccent);

    // Center Dot
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 4, Paint()..color = primaryColor);
  }

  void _drawHand(Canvas canvas, Offset center, double angleDeg, double length, double width, Color color) {
    final angle = (angleDeg - 90) * math.pi / 180;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    
    final end = Offset(
      center.dx + length * math.cos(angle),
      center.dy + length * math.sin(angle),
    );
    
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticleClockPainter oldDelegate) => true;
}
