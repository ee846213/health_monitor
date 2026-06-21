package com.example.health_monitor.background

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

/**
 * 在原生检测命中后立即发送安全提醒。
 *
 * 事件仍会进入 SharedPreferences 队列，供 Flutter 恢复前台后写入提醒历史；
 * 本通知不依赖 Dart isolate 或页面生命周期，因此可在应用退到后台时及时送达。
 */
class AndroidWalkingScreenRiskNotifier(
    private val context: Context,
    private val notificationManager: NotificationManager,
) {
    fun show(event: AndroidWalkingScreenRiskEvent): Boolean {
        if (!canPostNotifications()) {
            return false
        }

        ensureChannel()
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("先看路，再看手机")
            .setContentText("检测到你在移动时持续看屏，请先停下或收起手机。")
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText("检测到你在移动时持续看屏约 ${event.continuousWalkingSeconds} 秒。请先看路，停下后再操作手机。"),
            )
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_RECOMMENDATION)
            .setAutoCancel(true)
            .build()

        return runCatching {
            notificationManager.notify(NOTIFICATION_ID, notification)
            true
        }.getOrDefault(false)
    }

    private fun canPostNotifications(): Boolean {
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) {
            return false
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return true
        }
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.POST_NOTIFICATIONS,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val channel = NotificationChannel(
            CHANNEL_ID,
            "移动看屏风险提醒",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "检测到移动中持续看屏时发送安全提醒"
            enableVibration(true)
        }
        notificationManager.createNotificationChannel(channel)
    }

    companion object {
        const val CHANNEL_ID = "health_monitor_walking_screen_risk"
        private const val NOTIFICATION_ID = 2001
    }
}
