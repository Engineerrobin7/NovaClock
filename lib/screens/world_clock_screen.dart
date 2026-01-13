import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nova_clock/screens/add_timezone_screen.dart';
import 'package:nova_clock/services/world_clock_service.dart';
import 'package:nova_clock/widgets/custom_page_route.dart';
import 'package:nova_clock/widgets/glass_container.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class WorldClockScreen extends ConsumerStatefulWidget {
  const WorldClockScreen({super.key});

  @override
  ConsumerState<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends ConsumerState<WorldClockScreen> {
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void _addTimezone() async {
    final newTimezone = await Navigator.push(
      context,
      CustomPageRoute(builder: (context, _, __) => const AddTimezoneScreen()),
    );

    if (newTimezone != null) {
      try {
        await ref.read(worldClockProvider.notifier).addTimezone(newTimezone);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added timezone: $newTimezone')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding timezone: $e')),
          );
        }
      }
    }
  }

  void _removeTimezone(String timezone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Timezone'),
        content: Text('Are you sure you want to remove $timezone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(worldClockProvider.notifier).removeTimezone(timezone);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Removed: $timezone')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error removing timezone: $e')),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final worldClockState = ref.watch(worldClockProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: worldClockState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : worldClockState.timezones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.public_off,
                          size: 64,
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No timezones added',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to add a timezone',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: worldClockState.timezones.length,
                    itemBuilder: (context, index) {
                      final timezoneName = worldClockState.timezones[index];
                      
                      try {
                        final location = tz.getLocation(timezoneName);
                        final now = tz.TZDateTime.now(location);
                        final formattedTime = DateFormat.jm().format(now);
                        final formattedDate = DateFormat.yMMMMd().format(now);
                        final displayName = timezoneName.replaceAll('_', ' ').split('/').last;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () => _removeTimezone(timezoneName),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        // Handle invalid timezone gracefully
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timezoneName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Invalid timezone',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () => _removeTimezone(timezoneName),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _addTimezone,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
