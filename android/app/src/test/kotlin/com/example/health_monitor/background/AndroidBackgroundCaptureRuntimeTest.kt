package com.example.health_monitor.background

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureRuntimeTest {
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
        val runtime = AndroidBackgroundCaptureRuntime(
            AndroidForegroundServiceOrchestrator(scheduler),
        )

        val snapshot = runtime.start(
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
    fun stopShouldDelegateToOrchestrator() {
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = AndroidBackgroundCaptureController(
                    stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
                ),
            ),
            stateStore = InMemoryAndroidBackgroundCaptureStateStore(),
        )
        val runtime = AndroidBackgroundCaptureRuntime(
            AndroidForegroundServiceOrchestrator(scheduler),
        )

        runtime.start(
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

        val snapshot = runtime.stop()

        assertFalse(snapshot.isRunning)
    }
}
