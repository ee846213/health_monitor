package com.example.health_monitor.background

class AndroidBackgroundWorkManagerJob(
    private val scheduler: AndroidBackgroundCaptureScheduler,
) {
    fun runOnce(): AndroidBackgroundSchedulerSnapshot {
        // WorkManager 到点时只需要触发一次宿主刷新，
        // 这里不再引入新的业务分支，避免周期任务和手动刷新走出两套语义。
        return AndroidBackgroundCaptureWorker(scheduler).runOnce()
    }
}
