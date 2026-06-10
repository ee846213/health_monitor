package com.example.health_monitor.background

import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundWorkManagerJobTest {
    @Test
    fun runOnceShouldRefreshActiveSnapshot() {
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

        val job = AndroidBackgroundWorkManagerJob(scheduler)

        val snapshot = job.runOnce()

        assertTrue(snapshot.isRunning)
        assertTrue(snapshot.summary.contains("宿主骨架"))
    }
}
