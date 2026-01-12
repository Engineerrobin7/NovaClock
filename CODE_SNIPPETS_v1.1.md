# NovaClock v1.1 – Code Snippets & Integration Guide

## Quick Reference for All Changes

---

## 1. ANDROID NATIVE CODE (Kotlin)

### 1.1 AlarmScheduler – Schedule & Cancel Alarms

**Where to call from:**
```dart
// Dart (alarm_service.dart)
AlarmScheduler.scheduleAlarm(context, alarmId, triggerAtMillis);
AlarmScheduler.cancelAlarm(context, alarmId);
```

**Key method:**
```kotlin
// AlarmScheduler.kt
fun scheduleAlarm(context: Context, alarmId: Int, triggerAtMillis: Long) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    
    // Check permission (Android 12+)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        if (!hasExactAlarmPermission(context)) {
            scheduleInexactAlarm(context, alarmId, triggerAtMillis)
            return
        }
    }
    
    val pendingIntent = getPendingIntent(context, alarmId, triggerAtMillis)
    alarmManager.setExactAndAllowWhileIdle(
        AlarmManager.RTC_WAKEUP,
        triggerAtMillis,
        pendingIntent
    )
}
```

**Why `setExactAndAllowWhileIdle()`?**
- `setExact()` → Triggers at exact time (not within ±10 min window)
- `AllowWhileIdle()` → Triggers even in Doze mode (battery saver)
- `RTC_WAKEUP` → Wakes up device

---

### 1.2 AlarmReceiver – Broadcast When Alarm Fires

**Automatically triggered by Android when alarm time is reached:**
```kotlin
// AlarmReceiver.kt
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val alarmId = intent?.getIntExtra("alarmId", -1) ?: return
        AlarmNotificationManager.showAlarmNotification(context!!, alarmId, ...)
        AlarmWakeLockManager.acquireWakeLock(context, alarmId)
    }
}
```

**Registered in AndroidManifest:**
```xml
<receiver android:name=".AlarmReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.ALARM_TRIGGER" />
    </intent-filter>
</receiver>
```

---

### 1.3 BootReceiver – Reschedule After Reboot

**Automatically triggered after device restart:**
```kotlin
// BootReceiver.kt
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED && context != null) {
            AlarmScheduler.rescheduleAllAlarms(context)
        }
    }
}
```

**Registered in AndroidManifest:**
```xml
<receiver android:name=".BootReceiver" android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
```

---

### 1.4 WakeLock – Keep Device Awake

```kotlin
// AlarmWakeLockManager.kt
fun acquireWakeLock(context: Context, alarmId: Int) {
    val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
    val wakeLock = powerManager.newWakeLock(
        PowerManager.SCREEN_DIM_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
        "nova_clock:alarm_$alarmId"
    )
    wakeLock.acquire(10 * 60 * 1000L) // 10 minute timeout
}
```

**Flags:**
- `SCREEN_DIM_WAKE_LOCK` – Turn on screen (good for alarm)
- `ACQUIRE_CAUSES_WAKEUP` – Wake up device
- 10-minute timeout – Covers typical alarm snooze/dismiss

---

### 1.5 PermissionHelper – Check & Request Permissions

```kotlin
// PermissionHelper.kt
fun hasExactAlarmPermission(context: Context): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        context.checkSelfPermission("android.permission.SCHEDULE_EXACT_ALARM") 
            == PackageManager.PERMISSION_GRANTED
    } else {
        true
    }
}

fun getPermissionWarningMessage(context: Context): String? {
    val status = getAlarmPermissionStatus(context)
    return when {
        !status.hasExactAlarmPermission -> 
            "For accurate alarms, please grant 'Schedule exact alarms' permission in Settings."
        !status.isExcludedFromBatteryOptimization -> 
            "For alarms to work in battery saver mode, please exclude Nova Clock from battery optimization."
        else -> null
    }
}
```

---

### 1.6 MainActivity – Method Channel Setup

```kotlin
// MainActivity.kt
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, 
        "com.novaclock/alarms")
    
    methodChannel.setMethodCallHandler { call, result ->
        when (call.method) {
            "scheduleAlarm" -> {
                val alarmId = call.argument<Int>("alarmId")
                val triggerAtMillis = call.argument<Long>("triggerAtMillis")
                if (alarmId != null && triggerAtMillis != null) {
                    AlarmScheduler.scheduleAlarm(this, alarmId, triggerAtMillis)
                    result.success(null)
                }
            }
            "getPermissionWarning" -> {
                val warning = PermissionHelper.getPermissionWarningMessage(this)
                result.success(warning)
            }
            // ... other methods
            else -> result.notImplemented()
        }
    }
}
```

---

## 2. DART CODE (Flutter)

### 2.1 AlarmService – Schedule & Cancel from Dart

```dart
// lib/services/alarm_service.dart
class AlarmService extends StateNotifier<List<Alarm>> {
  static const platform = MethodChannel('com.novaclock/alarms');

  void addAlarm(DateTime time) {
    final newAlarm = Alarm(id: DateTime.now().toString(), time: time);
    state = [...state, newAlarm];
    _saveAlarms();
    _scheduleAlarmNatively(newAlarm);
  }

  void _scheduleAlarmNatively(Alarm alarm) {
    try {
      // Call Android native code
      platform.invokeMethod('scheduleAlarm', {
        'alarmId': alarm.id.hashCode,
        'triggerAtMillis': alarm.time.millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to schedule native alarm: $e');
    }
    
    // Fallback to Flutter notifications
    _notificationService.scheduleNotification(
      alarm.id.hashCode,
      'Nova Clock Alarm',
      'Time to wake up!',
      alarm.time,
    );
  }

  void removeAlarm(String id) {
    try {
      final alarm = state.firstWhere((a) => a.id == id);
      platform.invokeMethod('cancelAlarm', {'alarmId': alarm.id.hashCode});
    } catch (e) {
      print('Failed to cancel alarm: $e');
    }
    state = state.where((alarm) => alarm.id != id).toList();
    _saveAlarms();
  }

  void snoozeAlarm(String id, int minutes) {
    final alarm = state.firstWhere((a) => a.id == id);
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
    final snoozedAlarm = alarm.copyWith(time: snoozeTime);
    
    state = [...state.map((a) => a.id == id ? snoozedAlarm : a)];
    _saveAlarms();
    _scheduleAlarmNatively(snoozedAlarm);
  }
}
```

---

### 2.2 Smart Wake Preview – Model Methods

```dart
// lib/models/alarm_model.dart
class Alarm {
  final String id;
  final DateTime time;
  final bool isActive;

  /// Calculate time remaining until alarm
  Duration getTimeUntilAlarm() {
    final now = DateTime.now();
    var alarmTime = time;
    
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }
    
    return alarmTime.difference(now);
  }

  /// Human-readable format: "in 7h 42m"
  String getTimeUntilAlarmText() {
    final duration = getTimeUntilAlarm();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0) return 'in ${minutes}m';
    if (minutes == 0) return 'in ${hours}h';
    return 'in ${hours}h ${minutes}m';
  }

  /// Full preview: "You will wake up at 6:30 AM — in 7h 42m"
  String getSmartWakePreview() {
    final timeUntil = getTimeUntilAlarmText();
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    
    return 'You will wake up at $displayHour:$minute $period — $timeUntil';
  }
}
```

---

### 2.3 AlarmScreen – Improved UI with Smart Wake Preview

```dart
// lib/screens/alarm_screen.dart
class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  @override
  void initState() {
    super.initState();
    // Update preview every minute
    Future.delayed(const Duration(minutes: 1), _updatePreviews);
  }

  void _updatePreviews() {
    if (mounted) {
      setState(() {});
      Future.delayed(const Duration(minutes: 1), _updatePreviews);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);

    return Scaffold(
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large time text (40pt)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Row(
                      children: [
                        Switch(
                          value: alarm.isActive,
                          onChanged: (value) {
                            ref.read(alarmProvider.notifier).toggleAlarm(alarm.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => 
                            ref.read(alarmProvider.notifier).removeAlarm(alarm.id),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Smart Wake Preview
                if (alarm.isActive)
                  Text(
                    alarm.getSmartWakePreview(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

### 2.4 AlarmRingingScreen – Large Stop & Snooze Buttons

```dart
// lib/screens/alarm_ringing_screen.dart
class AlarmRingingScreen extends ConsumerStatefulWidget {
  final String alarmId;
  final DateTime alarmTime;

  const AlarmRingingScreen({
    super.key,
    required this.alarmId,
    required this.alarmTime,
  });

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.withOpacity(0.1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // STOP Button (200w x 80h)
            SizedBox(
              width: 200,
              height: 80,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(alarmProvider.notifier).dismissAlarm(widget.alarmId);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'STOP',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Snooze Options (5, 10, 15 min)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [5, 10, 15].map((minutes) => 
                SizedBox(
                  width: 90,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(alarmProvider.notifier)
                          .snoozeAlarm(widget.alarmId, minutes);
                      Navigator.of(context).pop();
                    },
                    child: Text('Snooze\n${minutes}m'),
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2.5 PermissionHelper – Check Permissions from Dart

```dart
// lib/utils/permission_helper.dart
class PermissionHelper {
  static const platform = MethodChannel('com.novaclock/alarms');

  static Future<PermissionStatus> getStatus() async {
    try {
      final result = await platform.invokeMethod<Map>('getPermissionStatus');
      if (result != null) {
        return PermissionStatus(
          hasExactAlarmPermission: result['hasExactAlarmPermission'] ?? false,
          isExcludedFromBatteryOptimization: result['isExcludedFromBatteryOptimization'] ?? false,
        );
      }
    } catch (e) {
      print('Failed to get permission status: $e');
    }
    return PermissionStatus(
      hasExactAlarmPermission: false,
      isExcludedFromBatteryOptimization: false,
    );
  }

  static Future<String?> getWarningMessage() async {
    try {
      return await platform.invokeMethod<String>('getPermissionWarning');
    } catch (e) {
      print('Failed to get warning: $e');
      return null;
    }
  }

  static Future<void> openExactAlarmSettings() async {
    try {
      await platform.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      print('Failed to open settings: $e');
    }
  }
}

class PermissionStatus {
  final bool hasExactAlarmPermission;
  final bool isExcludedFromBatteryOptimization;
  
  PermissionStatus({
    required this.hasExactAlarmPermission,
    required this.isExcludedFromBatteryOptimization,
  });
  
  bool get isComplete => hasExactAlarmPermission && isExcludedFromBatteryOptimization;
}
```

---

## 3. ANDROID MANIFEST

### 3.1 Required Permissions

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.SET_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 3.2 Receivers Registration

```xml
<receiver
    android:name=".AlarmReceiver"
    android:enabled="true"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.ALARM_TRIGGER" />
    </intent-filter>
</receiver>

<receiver
    android:name=".BootReceiver"
    android:enabled="true"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>
```

---

## 4. USAGE EXAMPLES

### Example 1: Add Alarm from UI
```dart
final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
if (time != null) {
  final dateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    time.hour,
    time.minute,
  );
  ref.read(alarmProvider.notifier).addAlarm(dateTime);
}
```

### Example 2: Check Permissions and Show Warning
```dart
final permStatus = await PermissionHelper.getStatus();
if (!permStatus.hasExactAlarmPermission) {
  final warning = await PermissionHelper.getWarningMessage();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(warning ?? 'Please grant permissions')),
  );
  
  // Redirect user
  await PermissionHelper.openExactAlarmSettings();
}
```

### Example 3: Snooze Alarm for 10 Minutes
```dart
ref.read(alarmProvider.notifier).snoozeAlarm(alarmId, 10);
```

### Example 4: Display Smart Wake Preview
```dart
final preview = alarm.getSmartWakePreview();
// Output: "You will wake up at 6:30 AM — in 7h 42m"
print(preview);
```

---

## 5. TESTING COMMANDS

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Kotlin compilation
./gradlew -c android/settings.gradle :app:compileKotlin

# View Android logs
adb logcat | grep -E "(AlarmReceiver|AlarmScheduler|AlarmWakeLock)"

# Trigger alarm manually (for testing)
adb shell am broadcast -a android.intent.action.ALARM_TRIGGER \
  --ei alarmId 12345 \
  --el alarmTime $(date +%s)000

# Simulate boot completed
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
```

---

## 6. KEY DESIGN DECISIONS

| Aspect | Decision | Why |
|--------|----------|-----|
| Alarm Method | Native AlarmManager | Reliable even when app is closed |
| Exact Timing | `setExactAndAllowWhileIdle()` | Works in battery saver mode |
| Fallback | Inexact alarms if permission denied | Graceful degradation |
| Wake Lock | `SCREEN_DIM_WAKE_LOCK` | Wakes up device and screen |
| Broadcast | Exported receivers | System can invoke them |
| Method Channel | Dart ↔ Kotlin | Bidirectional communication |
| Preview | Duration math (not cached) | Always accurate |
| UI | Large buttons, 40pt time | Accessibility & usability |

---

End of Code Snippets Reference
