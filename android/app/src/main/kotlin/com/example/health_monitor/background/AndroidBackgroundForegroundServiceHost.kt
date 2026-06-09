package com.example.health_monitor.background

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

class AndroidBackgroundForegroundServiceHost(
    private val gateway: AndroidBackgroundNotificationGateway,
) {
    fun createNotification(notification: AndroidBackgroundNotification): Notification {
        gateway.ensureChannel(notification.channelId)
        return gateway.createNotification(notification)
    }

    companion object {
        private const val CHANNEL_NAME = "健康监测后台运行"
    }
}

interface AndroidBackgroundNotificationGateway {
    fun ensureChannel(channelId: String)

    fun createNotification(notification: AndroidBackgroundNotification): Notification
}

class AndroidSystemNotificationGateway(
    private val context: Context,
    private val notificationManager: NotificationManager,
) : AndroidBackgroundNotificationGateway {
    override fun ensureChannel(channelId: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val channel = NotificationChannel(
            channelId,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        )
        notificationManager.createNotificationChannel(channel)
    }

    override fun createNotification(notification: AndroidBackgroundNotification): Notification {
        // 前台服务必须返回一个可展示的通知，这里统一把文案从调度层取出，避免服务层再拼业务信息。
        return NotificationCompat.Builder(context, notification.channelId)
            .setContentTitle(notification.title)
            .setContentText(notification.body)
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    companion object {
        private const val CHANNEL_NAME = "健康监测后台运行"
    }
}

class AndroidBackgroundForegroundServiceIntentFactory {
    fun createStartIntent(
        context: Context,
        request: AndroidBackgroundCaptureRequest,
    ): Intent {
        return Intent(context, AndroidBackgroundForegroundService::class.java)
            .setAction(ACTION_START)
            .putExtra(EXTRA_REQUEST, AndroidBackgroundCaptureRequestCodec.encode(request))
    }

    fun createStopIntent(context: Context): Intent {
        return Intent(context, AndroidBackgroundForegroundService::class.java)
            .setAction(ACTION_STOP)
    }

    fun createRefreshIntent(context: Context): Intent {
        return Intent(context, AndroidBackgroundForegroundService::class.java)
            .setAction(ACTION_REFRESH)
    }

    fun parseRequest(intent: Intent?): AndroidBackgroundCaptureRequest? {
        val serialized = intent?.getStringExtra(EXTRA_REQUEST) ?: return null
        return AndroidBackgroundCaptureRequestCodec.decode(serialized)
    }

    companion object {
        const val ACTION_START = "health_monitor.background.action.START"
        const val ACTION_STOP = "health_monitor.background.action.STOP"
        const val ACTION_REFRESH = "health_monitor.background.action.REFRESH"
        private const val EXTRA_REQUEST = "health_monitor.background.extra.REQUEST"
    }
}
