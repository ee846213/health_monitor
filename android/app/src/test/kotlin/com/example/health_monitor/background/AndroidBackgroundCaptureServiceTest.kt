package com.example.health_monitor.background

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureServiceTest {
    @Test
    fun startShouldDelegateToOrchestrator() {
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = AndroidBackgroundCaptureController(
                    stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
                ),
            ),
            stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
        )
        val service = AndroidBackgroundCaptureService(
            AndroidForegroundServiceOrchestrator(scheduler),
        )

        val snapshot = service.start(
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
        assertTrue(snapshot.notification.body.contains("周期 15 分钟"))
    }

    @Test
    fun stopShouldDelegateToOrchestrator() {
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = AndroidBackgroundCaptureController(
                    stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
                ),
            ),
            stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
        )
        val service = AndroidBackgroundCaptureService(
            AndroidForegroundServiceOrchestrator(scheduler),
        )

        service.start(
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

        val snapshot = service.stop()

        assertFalse(snapshot.isRunning)
        assertTrue(snapshot.notification.body.contains("停止"))
    }
}
