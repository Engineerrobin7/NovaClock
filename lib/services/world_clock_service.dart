import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// World Clock State
class WorldClockState {
  final List<String> timezones;
  final bool isLoading;

  const WorldClockState({
    this.timezones = const [
      'UTC',
      'America/New_York',
      'Europe/London',
      'Asia/Tokyo',
      'Australia/Sydney',
      'Asia/Kolkata',
    ],
    this.isLoading = false,
  });

  WorldClockState copyWith({
    List<String>? timezones,
    bool? isLoading,
  }) {
    return WorldClockState(
      timezones: timezones ?? this.timezones,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// World Clock Service
class WorldClockService extends StateNotifier<WorldClockState> {
  static const String _prefsKey = 'world_clock_timezones';

  WorldClockService() : super(const WorldClockState()) {
    _loadTimezones();
  }

  Future<void> _loadTimezones() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTimezones = prefs.getStringList(_prefsKey);

      if (savedTimezones != null && savedTimezones.isNotEmpty) {
        state = state.copyWith(timezones: savedTimezones);
      }
    } catch (e) {
      print('Error loading timezones: $e');
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> addTimezone(String timezone) async {
    try {
      final newTimezones = [...state.timezones, timezone];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, newTimezones);

      state = state.copyWith(timezones: newTimezones);
    } catch (e) {
      print('Error adding timezone: $e');
      rethrow;
    }
  }

  Future<void> removeTimezone(String timezone) async {
    try {
      final newTimezones = state.timezones
          .where((tz) => tz != timezone)
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, newTimezones);

      state = state.copyWith(timezones: newTimezones);
    } catch (e) {
      print('Error removing timezone: $e');
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    try {
      const defaultTimezones = [
        'UTC',
        'America/New_York',
        'Europe/London',
        'Asia/Tokyo',
        'Australia/Sydney',
        'Asia/Kolkata',
      ];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, defaultTimezones);

      state = state.copyWith(timezones: defaultTimezones);
    } catch (e) {
      print('Error resetting timezones: $e');
      rethrow;
    }
  }
}

// Provider
final worldClockProvider = StateNotifierProvider<WorldClockService, WorldClockState>((ref) {
  return WorldClockService();
});
