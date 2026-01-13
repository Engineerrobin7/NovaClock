import 'dart:convert';

class Alarm {
  final String id;
  final DateTime time;
  final bool isActive;
  final String label;
  final List<bool> repeatDays; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  final String sound;
  final int snoozeMinutes;

  Alarm({
    required this.id,
    required this.time,
    this.isActive = true,
    this.label = 'Alarm',
    this.repeatDays = const [false, false, false, false, false, false, false],
    this.sound = 'default',
    this.snoozeMinutes = 5,
  });

  Alarm copyWith({
    String? id,
    DateTime? time,
    bool? isActive,
    String? label,
    List<bool>? repeatDays,
    String? sound,
    int? snoozeMinutes,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      sound: sound ?? this.sound,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'label': label,
      'repeatDays': repeatDays,
      'sound': sound,
      'snoozeMinutes': snoozeMinutes,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'] as String,
      time: DateTime.parse(map['time'] as String),
      isActive: map['isActive'] as bool? ?? true,
      label: map['label'] as String? ?? 'Alarm',
      repeatDays: List<bool>.from(map['repeatDays'] as List? ?? []),
      sound: map['sound'] as String? ?? 'default',
      snoozeMinutes: map['snoozeMinutes'] as int? ?? 5,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Alarm.fromJson(String source) => Alarm.fromMap(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Alarm(id: $id, time: $time, isActive: $isActive, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Alarm &&
        other.id == id &&
        other.time == time &&
        other.isActive == isActive &&
        other.label == label &&
        other.repeatDays == repeatDays &&
        other.sound == sound &&
        other.snoozeMinutes == snoozeMinutes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        time.hashCode ^
        isActive.hashCode ^
        label.hashCode ^
        repeatDays.hashCode ^
        sound.hashCode ^
        snoozeMinutes.hashCode;
  }

  String getSmartWakePreview() {
    final now = DateTime.now();
    final duration = time.difference(now);
    
    if (duration.isNegative) {
      return 'Alarm passed';
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0 && minutes == 0) {
      return 'In less than a minute';
    } else if (hours == 0) {
      return 'In $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (minutes == 0) {
      return 'In $hours hour${hours == 1 ? '' : 's'}';
    } else {
      return 'In $hours h $minutes m';
    }
  }
}
