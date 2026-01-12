
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/services/timer_service.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final totalSeconds = timerState.duration.inSeconds;
    final remainingSeconds = timerState.remainingTime.inSeconds;
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Timer Display with Progress
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 10,
                      ),
                    ),
                  ),
                  // Progress Indicator
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  ),
                  // Glass Container for Time
                  GlassContainer(
                    width: 260,
                    height: 260,
                    borderRadius: BorderRadius.circular(130),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${timerState.remainingTime.inMinutes.toString().padLeft(2, '0')}:${(timerState.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontFeatures: [const FontFeature.tabularFigures()],
                              shadows: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                  blurRadius: 20,
                                )
                              ]
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            timerState.status == TimerStatus.running ? "REMAINING" : "SET TIMER",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Time Picker (Only visible when not running)
            if (timerState.status == TimerStatus.initial || timerState.status == TimerStatus.paused)
              SizedBox(
                height: 120,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    if (timerState.status != TimerStatus.running) {
                       ref.read(timerProvider.notifier).setDuration(Duration(minutes: index));
                    }
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final isSelected = index == timerState.duration.inMinutes;
                      return Center(
                        child: Text(
                          '$index min',
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 18,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.white30,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 61,
                  ),
                ),
              ),

            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.refresh,
                    label: "Reset",
                    onPressed: () {
                      ref.read(timerProvider.notifier).resetTimer();
                    },
                    color: Colors.redAccent,
                  ),
                  _buildControlButton(
                    icon: timerState.status == TimerStatus.running ? Icons.pause : Icons.play_arrow,
                    label: timerState.status == TimerStatus.running ? "Pause" : "Start",
                    onPressed: () {
                      if (timerState.status == TimerStatus.running) {
                        ref.read(timerProvider.notifier).stopTimer();
                      } else {
                        ref.read(timerProvider.notifier).startTimer();
                      }
                    },
                    isPrimary: true,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: isPrimary ? 80 : 60,
          height: isPrimary ? 80 : 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              side: BorderSide(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(icon, size: isPrimary ? 32 : 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}