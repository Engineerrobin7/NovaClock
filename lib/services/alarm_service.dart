import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_clock/models/alarm_model.dart';
import 'package:nova_clock/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final alarmProvider = StateNotifierProvider<AlarmService, List<Alarm>>((ref) {
  return AlarmService();
});

class AlarmService extends StateNotifier<List<Alarm>> {
  late final NotificationService _notificationService;
  
  // Method channel for communicating with Android native code
  static const platform = MethodChannel('com.novaclock/alarms');

  AlarmService() : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    _notificationService = NotificationService();
    await _notificationService.init();
    await _loadAlarms();
    await _initializeNativeAlarmSystem();
  }

  static const _alarmsKey = 'alarms';

  /// Initialize the native Android alarm system on first launch
  Future<void> _initializeNativeAlarmSystem() async {
    try {
      await platform.invokeMethod('initializeAlarmSystem');
    } catch (e) {
      print('Failed to initialize native alarm system: $e');
    }
  }

  /// Load alarms from persistent storage
  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmListString = prefs.getStringList(_alarmsKey);
    if (alarmListString != null) {
      state = alarmListString.map((s) => Alarm.fromJson(s)).toList();
      for (final alarm in state) {
        if (alarm.isActive) {
          _scheduleAlarmNatively(alarm);
        }
      }
    }
  }

  /// Save alarms to persistent storage
  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmListString = state.map((alarm) => alarm.toJson()).toList();
    await prefs.setStringList(_alarmsKey, alarmListString);
  }

  /// Schedule alarm both natively (Android) and with Flutter notifications
  /// This dual approach ensures reliability:
  /// - Android AlarmManager: Reliable even if app is closed or device reboots
  /// - Flutter notifications: Fallback if native fails, provides UI feedback
  Future<void> _scheduleAlarmNatively(Alarm alarm) async {
    try {
      // Schedule with native Android AlarmManager
      final result = await platform.invokeMethod('scheduleAlarm', {
        'alarmId': alarm.id.hashCode,
        'triggerAtMillis': alarm.time.millisecondsSinceEpoch,
      });
      print('✅ Native alarm scheduled: $result');
    } catch (e) {
      print('❌ Failed to schedule native alarm: $e');
    }

    // Also schedule with Flutter notifications as fallback
    try {
      await _notificationService.scheduleNotification(
        alarm.id.hashCode,
        'Nova Clock Alarm',
        'Time to wake up!',
        alarm.time,
      );
      print('✅ Notification scheduled for alarm: ${alarm.id}');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
    }
  }

  /// Cancel alarm both natively and in Flutter
  Future<void> _cancelAlarmNatively(Alarm alarm) async {
    try {
      await platform.invokeMethod('cancelAlarm', {
        'alarmId': alarm.id.hashCode,
      });
      print('✅ Native alarm cancelled: ${alarm.id}');
    } catch (e) {
      print('❌ Failed to cancel native alarm: $e');
    }

    try {
      await _notificationService.cancelNotification(alarm.id.hashCode);
      print('✅ Notification cancelled: ${alarm.id}');
    } catch (e) {
      print('❌ Failed to cancel notification: $e');
    }
  }

  /// Add a new alarm
  Future<void> addAlarm(DateTime time) async {
    final newAlarm = Alarm(id: DateTime.now().toString(), time: time);
    state = [...state, newAlarm];
    await _saveAlarms();
    await _scheduleAlarmNatively(newAlarm);
    print('➕ New alarm added: ${newAlarm.id} at ${newAlarm.time}');
  }

  /// Toggle alarm on/off
  Future<void> toggleAlarm(String id) async {
    try {
      final alarmToToggle = state.firstWhere(
        (alarm) => alarm.id == id,
        orElse: () => throw Exception('Alarm with id $id not found'),
      );
      final updatedAlarm = alarmToToggle.copyWith(isActive: !alarmToToggle.isActive);

      state = [
        for (final alarm in state)
          if (alarm.id == id)
            updatedAlarm
          else
            alarm,
      ];
      await _saveAlarms();

      if (updatedAlarm.isActive) {
        await _scheduleAlarmNatively(updatedAlarm);
        print('🔔 Alarm enabled: $id');
      } else {
        await _cancelAlarmNatively(updatedAlarm);
        print('🔕 Alarm disabled: $id');
      }
    } catch (e) {
      print('❌ Error toggling alarm: $e');
      rethrow;
    }
  }

  /// Remove an alarm
  Future<void> removeAlarm(String id) async {
    try {
      final alarmToRemove = state.firstWhere((alarm) => alarm.id == id);
      await _cancelAlarmNatively(alarmToRemove);
    } catch (e) {
      print('⚠️  Alarm not found, skipping cancel: $id');
    }
    state = state.where((alarm) => alarm.id != id).toList();
    await _saveAlarms();
    print('🗑️  Alarm removed: $id');
  }

  /// Snooze an active alarm by specified minutes
  /// Reschedules the alarm to trigger X minutes from now
  Future<void> snoozeAlarm(String id, int minutes) async {
    try {
      final alarmToSnooze = state.firstWhere((alarm) => alarm.id == id);
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
      final snoozedAlarm = alarmToSnooze.copyWith(time: snoozeTime);

      // Update state
      state = [
        for (final alarm in state)
          if (alarm.id == id)
            snoozedAlarm
          else
            alarm,
      ];
      await _saveAlarms();

      // Reschedule
      await _scheduleAlarmNatively(snoozedAlarm);
      print('⏰ Alarm snoozed: $id for $minutes minutes');
    } catch (e) {
      print('❌ Failed to snooze alarm: $e');
      rethrow;
    }
  }

  /// Check alarm permission status (Android 12+)
  /// Returns a message if permissions are missing
  Future<String?> checkAlarmPermissions() async {
    try {
      final result = await platform.invokeMethod<String>('getPermissionWarning');
      return result;
    } catch (e) {
      print('Failed to check permissions: $e');
      return null;
    }
  }

  /// Redirect user to exact alarm permission settings
  Future<void> openAlarmSettings() async {
    try {
      await platform.invokeMethod('openAlarmSettings');
    } catch (e) {
      print('Failed to open alarm settings: $e');
    }
  }

  /// Dismiss current alarm (stops ringing, clears notification)
  Future<void> dismissAlarm(String id) async {
    try {
      final alarm = state.firstWhere((a) => a.id == id);
      await platform.invokeMethod('dismissAlarm', {
        'alarmId': alarm.id.hashCode,
      });
    } catch (e) {
      print('Failed to dismiss alarm: $e');
    }
  }
}
