import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_clock/widgets/particle_clock.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  late DateTime _now;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive sizing logic
          final isSmallScreen = constraints.maxWidth < 400;
          final clockSize = isSmallScreen ? constraints.maxWidth * 0.7 : 300.0;
          final fontSizeTime = isSmallScreen ? 32.0 : 48.0;
          final fontSizeDate = isSmallScreen ? 16.0 : 20.0;

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Particle Clock with Glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          blurRadius: 80,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ParticleClock(size: clockSize),
                  ),
                  SizedBox(height: isSmallScreen ? 30 : 50),
                  Text(
                    DateFormat('h:mm:ss a').format(_now),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: fontSizeTime,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).primaryColor,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('EEEE, MMMM d').format(_now),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: fontSizeDate,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
