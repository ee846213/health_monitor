package com.example.health_monitor.background

class AndroidForegroundServiceOrchestrator(
    private val scheduler: AndroidBackgroundCaptureScheduler,
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundSchedulerSnapshot {
        // 先把真正的前台服务入口收口在这一层，后续接 Android Service 时只需要把这里替换成系统调用。
        return scheduler.start(request)
    }

    fun refresh(): AndroidBackgroundSchedulerSnapshot {
        return scheduler.refresh()
    }

    fun stop(): AndroidBackgroundSchedulerSnapshot {
        return scheduler.stop()
    }

    fun recover(message: String): AndroidBackgroundSchedulerSnapshot {
        return scheduler.markError(message)
    }
}
