import 'package:flutter/services.dart';

/// PermissionHelper: Manages alarm-related permissions on Android.
///
/// Handles:
/// 1. Checking SCHEDULE_EXACT_ALARM permission (Android 12+)
/// 2. Checking battery optimization exclusion
/// 3. Redirecting user to settings if permissions are missing
class PermissionHelper {
  static const platform = MethodChannel('com.novaclock/alarms');

  /// Check current permission status
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

  /// Get a user-friendly warning message if permissions are missing
  static Future<String?> getWarningMessage() async {
    try {
      final result = await platform.invokeMethod<String>('getPermissionWarning');
      return result;
    } catch (e) {
      print('Failed to get warning message: $e');
      return null;
    }
  }

  /// Redirect user to exact alarm permission settings
  static Future<void> openExactAlarmSettings() async {
    try {
      await platform.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      print('Failed to open exact alarm settings: $e');
    }
  }

  /// Redirect user to battery optimization settings
  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await platform.invokeMethod('openBatteryOptimizationSettings');
    } catch (e) {
      print('Failed to open battery optimization settings: $e');
    }
  }
}

/// PermissionStatus: Represents current alarm permission state
class PermissionStatus {
  final bool hasExactAlarmPermission;
  final bool isExcludedFromBatteryOptimization;

  PermissionStatus({
    required this.hasExactAlarmPermission,
    required this.isExcludedFromBatteryOptimization,
  });

  /// Returns true if all required permissions are granted
  bool get isComplete => hasExactAlarmPermission && isExcludedFromBatteryOptimization;

  /// Returns true if at least one permission is missing
  bool get isMissing => !isComplete;
}
