package com.example.health_monitor.background

data class AndroidBackgroundSchedulerSnapshot(
    val isRunning: Boolean,
    val notification: AndroidBackgroundNotification,
    val summary: String,
    val lastErrorMessage: String?,
)

class AndroidBackgroundCaptureScheduler(
    private val executor: AndroidBackgroundCaptureExecutor,
    private val composer: AndroidBackgroundNotificationComposer = AndroidBackgroundNotificationComposer(),
    private val stateStore: AndroidBackgroundCaptureStateStore = InMemoryAndroidBackgroundCaptureStateStore(),
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundSchedulerSnapshot {
        // 这里先把前台服务、调度与通知都收口到一个门面中，后面替换成真实 Service/WorkManager 时只改内部实现。
        val execution = executor.start(request)
        val notification = composer.compose(request, execution)
        writeState(
            activeRequest = request,
            summary = execution.summary,
            lastErrorMessage = null,
        )
        return AndroidBackgroundSchedulerSnapshot(
            isRunning = execution.isRunning,
            notification = notification,
            summary = execution.summary,
            lastErrorMessage = null,
        )
    }

    fun stop(): AndroidBackgroundSchedulerSnapshot {
        val execution = executor.stop()
        val notification = AndroidBackgroundNotification(
            title = "健康监测后台已停止",
            body = execution.summary,
            channelId = AndroidBackgroundNotificationComposer.CHANNEL_ID,
        )
        writeState(
            activeRequest = null,
            summary = execution.summary,
            lastErrorMessage = null,
        )
        return AndroidBackgroundSchedulerSnapshot(
            isRunning = execution.isRunning,
            notification = notification,
            summary = execution.summary,
            lastErrorMessage = null,
        )
    }

    fun markError(message: String): AndroidBackgroundSchedulerSnapshot {
        val execution = executor.markError(message)
        val notification = AndroidBackgroundNotification(
            title = "健康监测后台异常",
            body = execution.summary,
            channelId = AndroidBackgroundNotificationComposer.CHANNEL_ID,
        )
        writeState(
            activeRequest = currentState().activeRequest,
            summary = execution.summary,
            lastErrorMessage = message,
        )
        return AndroidBackgroundSchedulerSnapshot(
            isRunning = execution.isRunning,
            notification = notification,
            summary = execution.summary,
            lastErrorMessage = message,
        )
    }

    fun snapshot(): AndroidBackgroundSchedulerSnapshot {
        val execution = executor.snapshot()
        val notification = AndroidBackgroundNotification(
            title = currentState().activeRequest?.notificationTitle ?: "健康监测后台状态",
            body = execution.summary,
            channelId = AndroidBackgroundNotificationComposer.CHANNEL_ID,
        )
        return AndroidBackgroundSchedulerSnapshot(
            isRunning = execution.isRunning,
            notification = notification,
            summary = execution.summary,
            lastErrorMessage = currentState().lastErrorMessage,
        )
    }

    fun refresh(): AndroidBackgroundSchedulerSnapshot {
        val execution = executor.refresh()
        val request = currentState().activeRequest
        val notification = if (request == null) {
            AndroidBackgroundNotification(
                title = "健康监测后台状态",
                body = execution.summary,
                channelId = AndroidBackgroundNotificationComposer.CHANNEL_ID,
            )
        } else {
            composer.compose(request, execution)
        }
        return AndroidBackgroundSchedulerSnapshot(
            isRunning = execution.isRunning,
            notification = notification,
            summary = execution.summary,
            lastErrorMessage = currentState().lastErrorMessage,
        )
    }

    private fun writeState(
        activeRequest: AndroidBackgroundCaptureRequest?,
        summary: String,
        lastErrorMessage: String?,
    ) {
        stateStore.write(
            AndroidBackgroundCaptureState(
                activeRequest = activeRequest,
                lastErrorMessage = lastErrorMessage,
                lastSummary = summary,
            ),
        )
    }

    private fun currentState(): AndroidBackgroundCaptureState {
        return stateStore.read()
    }
}
