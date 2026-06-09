package com.example.health_monitor.background

data class AndroidBackgroundNotification(
    val title: String,
    val body: String,
    val channelId: String,
)

class AndroidBackgroundNotificationComposer {
    fun compose(request: AndroidBackgroundCaptureRequest, snapshot: AndroidBackgroundExecutionSnapshot): AndroidBackgroundNotification {
        // 通知标题保留用户明确配置的文案，正文则补充调度信息，方便用户理解为什么前台常驻还在运行。
        val body = if (snapshot.notificationBody.isBlank()) {
            request.notificationBody
        } else {
            snapshot.notificationBody
        }
        return AndroidBackgroundNotification(
            title = request.notificationTitle,
            body = body,
            channelId = CHANNEL_ID,
        )
    }

    companion object {
        const val CHANNEL_ID = "health_monitor_background"
    }
}
