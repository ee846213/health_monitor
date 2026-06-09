package com.example.health_monitor.background

class AndroidBackgroundCaptureRuntime(
    private val orchestrator: AndroidForegroundServiceOrchestrator,
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundSchedulerSnapshot {
        // 这层只负责把业务启动语义交给编排器，后续真正接入系统 Service 时不会改变这一接口。
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
