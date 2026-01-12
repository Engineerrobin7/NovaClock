package com.novaclock.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarm triggered!")
        
        val alarmId = intent.getIntExtra("alarmId", 0)
        
        // Acquire wake lock
        AlarmWakeLockManager.acquireWakeLock(context, 10)
        
        // Show notification
        AlarmNotificationManager.showAlarmNotification(context, alarmId)
        
        // Trigger activity
        val activityIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("alarmId", alarmId)
            action = "com.novaclock.ALARM_RINGING"
        }
        context.startActivity(activityIntent)
    }
}
