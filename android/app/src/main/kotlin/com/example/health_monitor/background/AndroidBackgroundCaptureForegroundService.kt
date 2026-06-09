package com.example.health_monitor.background

class AndroidBackgroundCaptureForegroundService(
    private val service: AndroidBackgroundCaptureService,
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundSchedulerSnapshot {
        // 这里将来会承接 Android 前台服务真正的 startForeground 行为，
        // 当前先把业务层的启动语义与系统服务边界绑定起来。
        return service.start(request)
    }

    fun refresh(): AndroidBackgroundSchedulerSnapshot {
        return service.refresh()
    }

    fun stop(): AndroidBackgroundSchedulerSnapshot {
        return service.stop()
    }

    fun recover(message: String): AndroidBackgroundSchedulerSnapshot {
        return service.recover(message)
    }
}
