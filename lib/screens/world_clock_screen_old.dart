import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nova_clock/screens/add_timezone_screen.dart';
import 'package:nova_clock/widgets/custom_page_route.dart';
import 'package:nova_clock/widgets/glass_container.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  final List<String> _timezones = [
    'America/New_York',
    'Europe/London',
    'Asia/Tokyo',
    'Australia/Sydney',
    'Asia/Dubai',
    'Asia/Kolkata',
  ];

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

    if (newTimezone != null && !_timezones.contains(newTimezone)) {
      setState(() {
        _timezones.add(newTimezone);
      });
    }
  }

  void _removeTimezone(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Timezone'),
        content: const Text('Are you sure you want to remove this timezone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _timezones.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: _timezones.length,
          itemBuilder: (context, index) {
            final timezoneName = _timezones[index];
            final location = tz.getLocation(timezoneName);
            final now = tz.TZDateTime.now(location);
            final formattedTime = DateFormat.jm().format(now);
            final formattedDate = DateFormat.yMMMMd().format(now);

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
                          timezoneName.replaceAll('_', ' ').split('/').last,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
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
                          icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                          onPressed: () => _removeTimezone(index),
                        ),
                      ],
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
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _addTimezone,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}