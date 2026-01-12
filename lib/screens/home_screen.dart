
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/services/alarm_service.dart';
import 'package:nova_clock/widgets/alarm_tile.dart';
import 'package:nova_clock/widgets/analog_clock.dart';
import 'package:nova_clock/widgets/digital_clock.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);

    return Container(
      color: const Color(0xFFE0E5EC),
      child: Column(
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: const AspectRatio(
                aspectRatio: 1,
                child: AnalogClock(),
              ),
            ),
            const SizedBox(height: 20),
            const DigitalClock(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return Dismissible(
                    key: Key(alarm.id),
                    onDismissed: (direction) {
                      ref.read(alarmProvider.notifier).removeAlarm(alarm.id);
                    },
                    child: AlarmTile(alarm: alarm),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
