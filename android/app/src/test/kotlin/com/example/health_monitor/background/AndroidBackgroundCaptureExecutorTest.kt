package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureExecutorTest {
    @Test
    fun startShouldBuildNotificationBodyFromPlan() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val executor = AndroidBackgroundCaptureExecutor(controller)
        val snapshot = executor.start(
            AndroidBackgroundCaptureRequest(
                notificationTitle = "健康监测正在后台运行",
                notificationBody = "用于持续积累活动、位置与用机样本。",
                enableMotion = true,
                enableLocation = true,
                enableNoise = false,
                enableDigitalUsage = true,
                sampleIntervalMinutes = 10,
            ),
        )

        assertTrue(snapshot.isRunning)
        assertTrue(snapshot.notificationBody.contains("周期 15 分钟"))
        assertEquals("健康监测正在后台运行", snapshot.notificationTitle)
    }
}
