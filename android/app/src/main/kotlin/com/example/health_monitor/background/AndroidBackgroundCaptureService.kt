package com.example.health_monitor.background

class AndroidBackgroundCaptureService(
    private val orchestrator: AndroidForegroundServiceOrchestrator,
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundSchedulerSnapshot {
        // 保留这层兼容门面，便于调试页、旧测试与原生服务入口继续共用同一套启动语义。
        return orchestrator.start(request)
    }

    fun stop(): AndroidBackgroundSchedulerSnapshot {
        return orchestrator.stop()
    }

    fun refresh(): AndroidBackgroundSchedulerSnapshot {
        return orchestrator.refresh()
    }

    fun recover(message: String): AndroidBackgroundSchedulerSnapshot {
        return orchestrator.recover(message)
    }
}
