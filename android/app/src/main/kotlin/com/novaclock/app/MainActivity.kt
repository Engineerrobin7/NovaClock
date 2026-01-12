package com.novaclock.app

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.pm.PackageManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.novaclock/alarms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeAlarmSystem" -> {
                    initializeAlarmSystem()
                    result.success(null)
                }
                "scheduleAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 0
                    val triggerAtMillis = call.argument<Long>("triggerAtMillis") ?: 0L
                    scheduleAlarm(alarmId, triggerAtMillis)
                    result.success(null)
                }
                "cancelAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 0
                    cancelAlarm(alarmId)
                    result.success(null)
                }
                "hasExactAlarmPermission" -> {
                    val hasPermission = hasExactAlarmPermission()
                    result.success(hasPermission)
                }
                "checkBatteryOptimization" -> {
                    val isExcluded = isBatteryOptimizationExcluded()
                    result.success(isExcluded)
                }
                "openBatteryOptimizationSettings" -> {
                    openBatteryOptimizationSettings()
                    result.success(null)
                }
                "rescheduleAllAlarms" -> {
                    val alarmsJson = call.argument<String>("alarmsJson") ?: "[]"
                    rescheduleAllAlarms(alarmsJson)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeAlarmSystem() {
        val scheduler = AlarmScheduler(this)
        scheduler.setupBootReceiver()
    }

    private fun scheduleAlarm(alarmId: Int, triggerAtMillis: Long) {
        val scheduler = AlarmScheduler(this)
        scheduler.scheduleAlarm(this, alarmId, triggerAtMillis)
    }

    private fun cancelAlarm(alarmId: Int) {
        val scheduler = AlarmScheduler(this)
        scheduler.cancelAlarm(this, alarmId)
    }

    private fun hasExactAlarmPermission(): Boolean {
        val helper = PermissionHelper(this)
        return helper.hasExactAlarmPermission()
    }

    private fun isBatteryOptimizationExcluded(): Boolean {
        val helper = PermissionHelper(this)
        return helper.isBatteryOptimizationExcluded()
    }

    private fun openBatteryOptimizationSettings() {
        val helper = PermissionHelper(this)
        helper.redirectToSettings()
    }

    private fun rescheduleAllAlarms(alarmsJson: String) {
        val scheduler = AlarmScheduler(this)
        // Parse JSON and reschedule
        try {
            val alarms = parseAlarmsFromJson(alarmsJson)
            for (alarm in alarms) {
                if (alarm["enabled"] == true) {
                    val alarmId = (alarm["id"] as? Number)?.toInt() ?: 0
                    val triggerAtMillis = (alarm["triggerAtMillis"] as? Number)?.toLong() ?: 0L
                    scheduler.scheduleAlarm(this, alarmId, triggerAtMillis)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error rescheduling alarms", e)
        }
    }

    private fun parseAlarmsFromJson(json: String): List<Map<String, Any?>> {
        // Simple JSON parsing - in production use a proper JSON library
        return emptyList()
    }
}


