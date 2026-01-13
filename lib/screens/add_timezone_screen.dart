import 'package:flutter/material.dart';

class AddTimezoneScreen extends StatefulWidget {
  const AddTimezoneScreen({super.key});

  @override
  State<AddTimezoneScreen> createState() => _AddTimezoneScreenState();
}

class _AddTimezoneScreenState extends State<AddTimezoneScreen> {
  late TextEditingController _searchController;
  List<String> _availableTimezones = [];
  List<String> _filteredTimezones = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadTimezones();
  }

  void _loadTimezones() {
    // Load available timezones - this would typically come from a timezone library
    _availableTimezones = [
      'UTC',
      'EST',
      'CST',
      'MST',
      'PST',
      'GMT',
      'CET',
      'IST',
      'JST',
      'AEST',
    ];
    _filteredTimezones = _availableTimezones;
  }

  void _filterTimezones(String query) {
    setState(() {
      _filteredTimezones = _availableTimezones
          .where((tz) => tz.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTimezones,
              decoration: InputDecoration(
                hintText: 'Search timezones...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTimezones.length,
              itemBuilder: (context, index) {
                final tz = _filteredTimezones[index];
                return ListTile(
                  title: Text(tz),
                  onTap: () {
                    Navigator.pop(context, tz);
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
