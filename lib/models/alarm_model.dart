import 'dart:convert';

class Alarm {
  final String id;
  final DateTime time;
  final bool isActive;
  final String? label; // Optional alarm label/description

  Alarm({
    required this.id,
    required this.time,
    this.isActive = true,
    this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'label': label,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      time: DateTime.parse(map['time']),
      isActive: map['isActive'] ?? true,
      label: map['label'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Alarm.fromJson(String source) => Alarm.fromMap(json.decode(source));

  Alarm copyWith({
    String? id,
    DateTime? time,
    bool? isActive,
    String? label,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
    );
  }

  /// Calculate time remaining until this alarm triggers
  Duration getTimeUntilAlarm() {
    final now = DateTime.now();
    var alarmTime = time;

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    return alarmTime.difference(now);
  }

  /// Get human-readable string for time until alarm
  String getTimeUntilAlarmText() {
    final duration = getTimeUntilAlarm();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return 'in ${minutes}m';
    } else if (minutes == 0) {
      return 'in ${hours}h';
    } else {
      return 'in ${hours}h ${minutes}m';
    }
  }

  /// Get smart wake preview text
  String getSmartWakePreview() {
    final timeUntil = getTimeUntilAlarmText();
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    
    return 'You will wake up at $displayHour:$minute $period — $timeUntil';
  }

  @override
  String toString() => 'Alarm($id, $time, active=$isActive, label=$label)';
}