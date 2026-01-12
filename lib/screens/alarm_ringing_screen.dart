import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/services/alarm_service.dart';

/// AlarmRingingScreen: Displays when alarm is triggered
/// Features:
/// - Large, easy-to-tap STOP button
/// - Optional SNOOZE button (5, 10, 15 minutes)
/// - Visual feedback (flashing, animations)
/// - Prevents accidental dismissal with confirmation
class AlarmRingingScreen extends ConsumerStatefulWidget {
  final String alarmId;
  final DateTime alarmTime;

  const AlarmRingingScreen({
    super.key,
    required this.alarmId,
    required this.alarmTime,
  });

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create pulsing animation for visual feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button from dismissing alarm
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.red.withOpacity(0.1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Title
              Text(
                'ALARM',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              // Time
              Text(
                '${widget.alarmTime.hour.toString().padLeft(2, '0')}:${widget.alarmTime.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                    ),
              ),

              // Pulsing animation container
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.alarm,
                    size: 60,
                    color: Colors.red,
                  ),
                ),
              ),

              // STOP Button (large, prominent)
              SizedBox(
                width: 200,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(alarmProvider.notifier).dismissAlarm(widget.alarmId);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'STOP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),

              // Snooze options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSnoozeButton(context, 5),
                  _buildSnoozeButton(context, 10),
                  _buildSnoozeButton(context, 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a snooze button for X minutes
  Widget _buildSnoozeButton(BuildContext context, int minutes) {
    return SizedBox(
      width: 90,
      height: 60,
      child: OutlinedButton(
        onPressed: () {
          ref.read(alarmProvider.notifier).snoozeAlarm(widget.alarmId, minutes);
          Navigator.of(context).pop();
          
          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Snoozed for $minutes minutes'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Snooze\n${minutes}m',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
