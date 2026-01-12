package com.novaclock.app

import android.content.Context
import android.os.PowerManager
import android.util.Log

object AlarmWakeLockManager {
    private var wakeLock: PowerManager.WakeLock? = null
    
    fun acquireWakeLock(context: Context, timeoutMinutes: Int = 10) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return
            
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "novaclock:alarm_wakelock"
            ).apply {
                acquire((timeoutMinutes * 60 * 1000).toLong())
            }
            
            Log.d("AlarmWakeLockManager", "Wake lock acquired for $timeoutMinutes minutes")
        } catch (e: Exception) {
            Log.e("AlarmWakeLockManager", "Error acquiring wake lock", e)
        }
    }
    
    fun releaseWakeLock() {
        try {
            wakeLock?.takeIf { it.isHeld }?.release()
            wakeLock = null
            Log.d("AlarmWakeLockManager", "Wake lock released")
        } catch (e: Exception) {
            Log.e("AlarmWakeLockManager", "Error releasing wake lock", e)
        }
    }
}
