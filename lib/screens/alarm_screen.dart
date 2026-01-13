
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/services/alarm_service.dart';
import 'package:nova_clock/widgets/glass_container.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    // Update Smart Wake Preview every minute
    Future.delayed(const Duration(minutes: 1), _updatePreviews);
  }

  void _updatePreviews() {
    if (mounted) {
      setState(() {});
      Future.delayed(const Duration(minutes: 1), _updatePreviews);
    }
  }

  @override
  Widget build(BuildContext context) {
    // `ConsumerState` provides `ref` as a member; do not accept it as a parameter.
    final alarms = ref.watch(alarmProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: alarms.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_off_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No alarms set',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alarm time (larger, more prominent)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(fontSize: 40, fontWeight: FontWeight.w300),
                              ),
                              Row(
                                children: [
                                  // Toggle switch
                                  Switch(
                                    value: alarm.isActive,
                                    onChanged: (value) {
                                      ref
                                          .read(alarmProvider.notifier)
                                          .toggleAlarm(alarm.id);
                                    },
                                    activeThumbColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 24,
                                    ),
                                    onPressed: () => ref
                                        .read(alarmProvider.notifier)
                                        .removeAlarm(alarm.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Smart Wake Preview (only if active)
                          if (alarm.isActive)
                            Text(
                              alarm.getSmartWakePreview(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                            )
                          else
                            Text(
                              'Alarm inactive',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              final now = DateTime.now();
              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              );
              ref.read(alarmProvider.notifier).addAlarm(dateTime);

              // Show confirmation
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Alarm set for ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Alarm', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

}
