import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = '00:00:00';
  final List<String> _laps = [];

  void _startStop() {
    if (mounted) {
      setState(() {
        if (_stopwatch.isRunning) {
          _stopwatch.stop();
          _timer?.cancel();
        } else {
          _stopwatch.start();
          _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
            if (mounted) {
              setState(() {
                _elapsedTime = formatTime(_stopwatch.elapsedMilliseconds);
              });
            } else {
              timer.cancel();
            }
          });
        }
      });
    }
  }

  void _reset() {
    if (!_stopwatch.isRunning && _stopwatch.elapsedMilliseconds > 0) {
      _timer?.cancel();
      _stopwatch.reset();
      if (mounted) {
        setState(() {
          _elapsedTime = '00:00:00';
          _laps.clear();
        });
      }
    }
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      if (mounted) {
        setState(() {
          _laps.insert(0, formatTime(_stopwatch.elapsedMilliseconds));
        });
      }
    }
  }

  String formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr:$hundredsStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Timer Display
            Center(
              child: GlassContainer(
                width: 300,
                height: 300,
                borderRadius: BorderRadius.circular(150),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _elapsedTime,
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
                        "STOPWATCH",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.flag,
                  label: "Lap",
                  onPressed: _stopwatch.isRunning ? _lap : null,
                  color: Colors.blueAccent,
                ),
                _buildControlButton(
                  icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                  label: _stopwatch.isRunning ? "Pause" : "Start",
                  onPressed: _startStop,
                  isPrimary: true,
                  color: Theme.of(context).primaryColor,
                ),
                _buildControlButton(
                  icon: Icons.refresh,
                  label: "Reset",
                  onPressed: (!_stopwatch.isRunning && _stopwatch.elapsedMilliseconds > 0) ? _reset : null,
                  color: Colors.redAccent,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Laps List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _laps.isEmpty 
                  ? Center(
                      child: Text(
                        "No laps recorded",
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _laps.length,
                      itemBuilder: (context, index) {
                        final lapIndex = _laps.length - index;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lap $lapIndex',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  _laps[index],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
    required VoidCallback? onPressed,
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
            boxShadow: onPressed != null ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: onPressed != null ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              foregroundColor: color,
              side: BorderSide(
                color: onPressed != null ? color : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(icon, size: isPrimary ? 32 : 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: onPressed != null ? Colors.white70 : Colors.white30,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}