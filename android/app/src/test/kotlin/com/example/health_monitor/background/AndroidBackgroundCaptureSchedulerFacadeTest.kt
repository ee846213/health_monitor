package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureSchedulerFacadeTest {
    @Test
    fun refreshShouldPreserveLastErrorAndRefreshNotification() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = store,
        )

        scheduler.start(
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
        scheduler.markError("前台服务启动失败")
        val snapshot = scheduler.refresh()

        assertTrue(snapshot.isRunning)
        assertEquals("前台服务启动失败", snapshot.lastErrorMessage)
        assertTrue(snapshot.notification.body.contains("周期 15 分钟"))
    }

    @Test
    fun stopShouldClearRunningState() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = store,
        )

        scheduler.start(
            AndroidBackgroundCaptureRequest(
                notificationTitle = "健康监测正在后台运行",
                notificationBody = "用于持续积累活动、位置与用机样本。",
                enableMotion = true,
                enableLocation = true,
                enableNoise = false,
                enableDigitalUsage = true,
                sampleIntervalMinutes = 15,
            ),
        )

        val snapshot = scheduler.stop()

        assertFalse(snapshot.isRunning)
        assertEquals(null, snapshot.lastErrorMessage)
        assertTrue(snapshot.notification.body.contains("停止"))
    }
}
