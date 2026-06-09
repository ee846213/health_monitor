package com.example.health_monitor.background

class AndroidBackgroundCaptureWorker(
    private val scheduler: AndroidBackgroundCaptureScheduler,
) {
    fun runOnce(): AndroidBackgroundSchedulerSnapshot {
        // 先保守地做状态刷新，避免没有活跃请求时误触发空采集。
        return if (scheduler.snapshot().isRunning) {
            scheduler.refresh()
        } else {
            scheduler.snapshot()
        }
    }
}
