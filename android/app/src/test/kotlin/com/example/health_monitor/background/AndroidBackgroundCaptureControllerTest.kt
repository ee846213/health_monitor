package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureControllerTest {
    @Test
    fun startShouldPersistRequestAndReportRunningState() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val request = AndroidBackgroundCaptureRequest(
            notificationTitle = "健康监测正在后台运行",
            notificationBody = "用于持续积累活动、位置与用机样本。",
            enableMotion = true,
            enableLocation = true,
            enableNoise = false,
            enableDigitalUsage = true,
            sampleIntervalMinutes = 15,
        )

        val snapshot = controller.start(request)

        assertTrue(snapshot.isRunning)
        assertTrue(snapshot.summary.contains("活动"))
        assertEquals(request, store.read().activeRequest)
    }

    @Test
    fun stopShouldClearRequestAndReportStoppedState() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        controller.start(
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

        val snapshot = controller.stop()

        assertFalse(snapshot.isRunning)
        assertTrue(snapshot.summary.contains("停止"))
        assertEquals(null, store.read().activeRequest)
    }

    @Test
    fun errorShouldBeRecordedForRecovery() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)

        controller.markError("后台服务启动失败")
        val snapshot = controller.snapshot()

        assertFalse(snapshot.isRunning)
        assertTrue(snapshot.summary.contains("失败"))
        assertEquals("后台服务启动失败", store.read().lastErrorMessage)
    }
}
