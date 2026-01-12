import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings State
class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool alarmNotifications;
  final bool timerNotifications;
  final bool focusNotifications;
  final String alarmSound;
  final String notificationSound;
  final int accentColorIndex;

  const SettingsState({
    this.isDarkMode = true,
    this.notificationsEnabled = true,
    this.alarmNotifications = true,
    this.timerNotifications = true,
    this.focusNotifications = true,
    this.alarmSound = 'default',
    this.notificationSound = 'default',
    this.accentColorIndex = 0,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? alarmNotifications,
    bool? timerNotifications,
    bool? focusNotifications,
    String? alarmSound,
    String? notificationSound,
    int? accentColorIndex,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      alarmNotifications: alarmNotifications ?? this.alarmNotifications,
      timerNotifications: timerNotifications ?? this.timerNotifications,
      focusNotifications: focusNotifications ?? this.focusNotifications,
      alarmSound: alarmSound ?? this.alarmSound,
      notificationSound: notificationSound ?? this.notificationSound,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
    );
  }
}

// Settings Service
class SettingsService extends StateNotifier<SettingsState> {
  SettingsService() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = SettingsState(
      isDarkMode: prefs.getBool('isDarkMode') ?? true,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      alarmNotifications: prefs.getBool('alarmNotifications') ?? true,
      timerNotifications: prefs.getBool('timerNotifications') ?? true,
      focusNotifications: prefs.getBool('focusNotifications') ?? true,
      alarmSound: prefs.getString('alarmSound') ?? 'default',
      notificationSound: prefs.getString('notificationSound') ?? 'default',
      accentColorIndex: prefs.getInt('accentColorIndex') ?? 0,
    );
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.notificationsEnabled;
    await prefs.setBool('notificationsEnabled', newValue);
    state = state.copyWith(notificationsEnabled: newValue);
  }

  Future<void> toggleAlarmNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.alarmNotifications;
    await prefs.setBool('alarmNotifications', newValue);
    state = state.copyWith(alarmNotifications: newValue);
  }

  Future<void> toggleTimerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.timerNotifications;
    await prefs.setBool('timerNotifications', newValue);
    state = state.copyWith(timerNotifications: newValue);
  }

  Future<void> toggleFocusNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.focusNotifications;
    await prefs.setBool('focusNotifications', newValue);
    state = state.copyWith(focusNotifications: newValue);
  }

  Future<void> setAlarmSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarmSound', sound);
    state = state.copyWith(alarmSound: sound);
  }

  Future<void> setNotificationSound(String sound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationSound', sound);
    state = state.copyWith(notificationSound: sound);
  }

  Future<void> setAccentColor(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColorIndex', index);
    state = state.copyWith(accentColorIndex: index);
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsService, SettingsState>((ref) {
  return SettingsService();
});
