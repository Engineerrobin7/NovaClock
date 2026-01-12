package com.novaclock.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

object AlarmNotificationManager {
    private const val CHANNEL_ID = "alarm_channel"
    private const val NOTIFICATION_ID = 1001
    
    fun showAlarmNotification(context: Context, alarmId: Int) {
        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
            
            // Create notification channel for Android 8+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Alarm Notifications",
                    NotificationManager.IMPORTANCE_MAX
                ).apply {
                    description = "Notifications for alarm events"
                    enableVibration(true)
                    enableLights(true)
                }
                notificationManager.createNotificationChannel(channel)
            }
            
            // Create intent to open app
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("alarmId", alarmId)
                action = "com.novaclock.ALARM_RINGING"
            }
            
            val pendingIntent = PendingIntent.getActivity(
                context,
                alarmId,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setContentTitle("Alarm")
                .setContentText("Your alarm is ringing")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .build()
            
            notificationManager.notify(NOTIFICATION_ID, notification)
            Log.d("AlarmNotificationManager", "Notification displayed for alarm $alarmId")
        } catch (e: Exception) {
            Log.e("AlarmNotificationManager", "Error showing notification", e)
        }
    }
}
