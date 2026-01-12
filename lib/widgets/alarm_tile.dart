
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nova_clock/models/alarm_model.dart';
import 'package:nova_clock/services/alarm_service.dart';

class AlarmTile extends ConsumerWidget {
  final Alarm alarm;

  const AlarmTile({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedTime = DateFormat.jm().format(alarm.time);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC1C8D1),
            offset: Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          formattedTime,
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
        ),
        trailing: Theme(
          data: Theme.of(context).copyWith(
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Colors.grey;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  final pv = Theme.of(context).colorScheme.primary.toARGB32();
                  return Color.fromARGB((0.4 * 255).round(), (pv >> 16) & 0xFF, (pv >> 8) & 0xFF, pv & 0xFF);
                }
                return const Color.fromRGBO(158, 158, 158, 0.3);
              }),
            ),
          ),
          child: Switch(
            value: alarm.isActive,
            onChanged: (value) {
              ref.read(alarmProvider.notifier).toggleAlarm(alarm.id);
            },
          ),
        ),
      ),
    );
  }
}
