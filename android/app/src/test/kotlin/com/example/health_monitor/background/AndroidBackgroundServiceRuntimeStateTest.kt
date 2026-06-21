package com.example.health_monitor.background

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundServiceRuntimeStateTest {
    @Test
    fun persistedRunningStateShouldNotMasqueradeAsLiveService() {
        val persistedSnapshot = AndroidBackgroundSchedulerSnapshot(
            isRunning = true,
            notification = AndroidBackgroundNotification(
                title = "后台运行",
                body = "正在采集",
                channelId = "background",
            ),
            summary = "后台采集运行中",
            lastErrorMessage = null,
        )

        val resolved = persistedSnapshot.withRuntimeServiceState(serviceRunning = false)

        assertFalse(resolved.isRunning)
        assertTrue(resolved.summary.contains("自动恢复"))
    }

    @Test
    fun liveServiceShouldPreserveRunningState() {
        val persistedSnapshot = AndroidBackgroundSchedulerSnapshot(
            isRunning = true,
            notification = AndroidBackgroundNotification(
                title = "后台运行",
                body = "正在采集",
                channelId = "background",
            ),
            summary = "后台采集运行中",
            lastErrorMessage = null,
        )

        val resolved = persistedSnapshot.withRuntimeServiceState(serviceRunning = true)

        assertTrue(resolved.isRunning)
    }
}
