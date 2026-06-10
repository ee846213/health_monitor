package com.example.health_monitor.background

import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundWorkManagerWorkerFallbackTest {
    @Test
    fun workerRetryStateShouldBePersistedThroughScheduler() {
        val store = InMemoryAndroidBackgroundCaptureStateStore()
        val controller = AndroidBackgroundCaptureController(store)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = store,
        )

        val snapshot = scheduler.markError("后台任务执行失败")

        assertTrue(snapshot.summary.contains("失败"))
        assertTrue(store.read().lastErrorMessage?.contains("后台任务执行失败") == true)
    }
}
