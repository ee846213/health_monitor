package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidBackgroundNotificationComposerGatewayTest {
    @Test
    fun composeShouldPreserveRequestContentForActiveExecution() {
        val composer = AndroidBackgroundNotificationComposer()
        val request = AndroidBackgroundCaptureRequest(
            notificationTitle = "健康监测正在后台运行",
            notificationBody = "用于持续积累活动、位置与用机样本。",
            enableMotion = true,
            enableLocation = true,
            enableNoise = false,
            enableDigitalUsage = true,
            sampleIntervalMinutes = 15,
        )
        val execution = AndroidBackgroundExecutionSnapshot(
            isRunning = true,
            notificationTitle = request.notificationTitle,
            notificationBody = "用于持续积累活动、位置与用机样本。当前调度能力：motion、location、digital_usage；周期 15 分钟。",
            summary = "Android 后台采集已进入宿主骨架阶段，当前计划采集：活动、位置、数字生活；采样间隔 15 分钟。",
        )

        val notification = composer.compose(request, execution)

        assertEquals(request.notificationTitle, notification.title)
        assertEquals(execution.notificationBody, notification.body)
        assertEquals(AndroidBackgroundNotificationComposer.CHANNEL_ID, notification.channelId)
    }
}
