package com.novaclock.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.content.pm.PackageManager
import android.Manifest

class AlarmScheduler(private val context: Context) {
    fun scheduleAlarm(context: Context, alarmId: Int, triggerAtMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        
        Log.d("AlarmScheduler", "Scheduling alarm $alarmId for $triggerAtMillis")
        
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context, 
            alarmId, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Android 12+ requires SCHEDULE_EXACT_ALARM permission
                if (context.checkSelfPermission(Manifest.permission.SCHEDULE_EXACT_ALARM) == PackageManager.PERMISSION_GRANTED) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d("AlarmScheduler", "Scheduled with exact alarm (Android 12+)")
                } else {
                    // Fallback to setAndAllowWhileIdle without exact timing
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerAtMillis,
                        pendingIntent
                    )
                    Log.d("AlarmScheduler", "Scheduled without exact alarm (permission missing)")
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                )
                Log.d("AlarmScheduler", "Scheduled with exact alarm (Android <12)")
            }
        } catch (e: Exception) {
            Log.e("AlarmScheduler", "Error scheduling alarm", e)
        }
    }
    
    fun cancelAlarm(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
        Log.d("AlarmScheduler", "Cancelled alarm $alarmId")
    }
    
    fun rescheduleAllAlarms(context: Context) {
        // This will be called after device boot
        Log.d("AlarmScheduler", "Rescheduling all alarms after boot")
        // The actual rescheduling is handled by the Flutter layer
    }
    
    fun setupBootReceiver() {
        Log.d("AlarmScheduler", "Boot receiver setup")
    }
}
