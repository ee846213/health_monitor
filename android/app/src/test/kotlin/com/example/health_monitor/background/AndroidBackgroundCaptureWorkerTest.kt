package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureWorkerTest {
    @Test
    fun runOnceShouldRefreshWhenSchedulerIsRunning() {
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

        val worker = AndroidBackgroundCaptureWorker(scheduler)
        val snapshot = worker.runOnce()

        assertTrue(snapshot.isRunning)
        assertTrue(snapshot.notification.body.contains("周期 15 分钟"))
    }

    @Test
    fun runOnceShouldStayIdleWhenSchedulerStopped() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = store,
        )

        val worker = AndroidBackgroundCaptureWorker(scheduler)
        val snapshot = worker.runOnce()

        assertFalse(snapshot.isRunning)
        assertEquals("Android 后台采集尚未启动。", snapshot.summary)
    }
}
