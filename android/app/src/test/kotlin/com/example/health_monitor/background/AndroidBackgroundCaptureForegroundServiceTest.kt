package com.example.health_monitor.background

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureForegroundServiceTest {
    @Test
    fun startShouldDelegateToBackgroundService() {
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = AndroidBackgroundCaptureController(
                    stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
                ),
            ),
            stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
        )
        val service = AndroidBackgroundCaptureForegroundService(
            AndroidBackgroundCaptureService(
                AndroidForegroundServiceOrchestrator(scheduler),
            ),
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
    }

    @Test
    fun recoverShouldDelegateToBackgroundService() {
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = AndroidBackgroundCaptureController(
                    stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
                ),
            ),
            stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
        )
        val service = AndroidBackgroundCaptureForegroundService(
            AndroidBackgroundCaptureService(
                AndroidForegroundServiceOrchestrator(scheduler),
            ),
        )

        val snapshot = service.recover("前台服务启动失败")

        assertFalse(snapshot.isRunning)
        assertTrue(snapshot.summary.contains("失败"))
    }
}
