package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidBackgroundNotificationComposerTest {
    @Test
    fun composeShouldReuseRequestTitleAndExpandedBody() {
        val composer = AndroidBackgroundNotificationComposer()
        val notification = composer.compose(
            AndroidBackgroundCaptureRequest(
                notificationTitle = "健康监测正在后台运行",
                notificationBody = "用于持续积累活动、位置与用机样本。",
                enableMotion = true,
                enableLocation = true,
                enableNoise = false,
                enableDigitalUsage = true,
                sampleIntervalMinutes = 15,
            ),
            AndroidBackgroundExecutionSnapshot(
                isRunning = true,
                notificationTitle = "健康监测正在后台运行",
                notificationBody = "用于持续积累活动、位置与用机样本。 当前调度能力：motion、location、digital_usage；周期 15 分钟。",
                summary = "Android 后台采集已进入宿主骨架阶段。",
            ),
        )

        assertEquals("健康监测正在后台运行", notification.title)
        assertEquals(AndroidBackgroundNotificationComposer.CHANNEL_ID, notification.channelId)
        assertEquals(
            "用于持续积累活动、位置与用机样本。 当前调度能力：motion、location、digital_usage；周期 15 分钟。",
            notification.body,
        )
    }
}
