package com.example.health_monitor.background

data class AndroidBackgroundExecutionSnapshot(
    val isRunning: Boolean,
    val notificationTitle: String,
    val notificationBody: String,
    val summary: String,
)

class AndroidBackgroundCaptureExecutor(
    private val controller: AndroidBackgroundCaptureController,
    private val planner: AndroidBackgroundCaptureTaskPlanner = AndroidBackgroundCaptureTaskPlanner(),
) {
    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundExecutionSnapshot {
        val plan = planner.resolve(request)
        val snapshot = controller.start(request)
        return AndroidBackgroundExecutionSnapshot(
            isRunning = snapshot.isRunning,
            notificationTitle = request.notificationTitle,
            notificationBody = buildNotificationBody(request, plan),
            summary = snapshot.summary,
        )
    }

    fun stop(): AndroidBackgroundExecutionSnapshot {
        val snapshot = controller.stop()
        return AndroidBackgroundExecutionSnapshot(
            isRunning = snapshot.isRunning,
            notificationTitle = "",
            notificationBody = snapshot.summary,
            summary = snapshot.summary,
        )
    }

    fun markError(message: String): AndroidBackgroundExecutionSnapshot {
        val snapshot = controller.markError(message)
        return AndroidBackgroundExecutionSnapshot(
            isRunning = snapshot.isRunning,
            notificationTitle = "",
            notificationBody = snapshot.summary,
            summary = snapshot.summary,
        )
    }

    fun snapshot(): AndroidBackgroundExecutionSnapshot {
        val snapshot = controller.snapshot()
        return AndroidBackgroundExecutionSnapshot(
            isRunning = snapshot.isRunning,
            notificationTitle = "",
            notificationBody = snapshot.summary,
            summary = snapshot.summary,
        )
    }

    fun refresh(): AndroidBackgroundExecutionSnapshot {
        val snapshot = controller.refresh()
        val request = controller.currentRequest()
        return AndroidBackgroundExecutionSnapshot(
            isRunning = snapshot.isRunning,
            notificationTitle = request?.notificationTitle ?: "",
            notificationBody = request?.let { buildNotificationBody(it, planner.resolve(it)) } ?: snapshot.summary,
            summary = snapshot.summary,
        )
    }

    private fun buildNotificationBody(
        request: AndroidBackgroundCaptureRequest,
        plan: AndroidBackgroundCaptureTaskPlan,
    ): String {
        val capabilitySummary = if (plan.capabilityTags.isEmpty()) {
            "未启用具体采集能力"
        } else {
            plan.capabilityTags.joinToString(separator = "、")
        }
        return "${request.notificationBody} 当前调度能力：$capabilitySummary；周期 ${plan.cadenceMinutes} 分钟。"
    }
}
