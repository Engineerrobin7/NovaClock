import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AddTimezoneScreen extends StatefulWidget {
  const AddTimezoneScreen({super.key});

  @override
  State<AddTimezoneScreen> createState() => _AddTimezoneScreenState();
}

class _AddTimezoneScreenState extends State<AddTimezoneScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allTimezones = [];
  List<String> _filteredTimezones = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList();
    _filteredTimezones = _allTimezones;
    _searchController.addListener(() {
      _filterTimezones();
    });
  }

  void _filterTimezones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTimezones = _allTimezones
          .where((timezone) => timezone.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timezone'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTimezones.length,
              itemBuilder: (context, index) {
                final timezoneName = _filteredTimezones[index];
                return ListTile(
                  title: Text(timezoneName.replaceAll('_', ' ')),
                  onTap: () {
                    Navigator.pop(context, timezoneName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
