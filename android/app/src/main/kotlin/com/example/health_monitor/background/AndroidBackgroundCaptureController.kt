package com.example.health_monitor.background

data class AndroidBackgroundCaptureRequest(
    val notificationTitle: String,
    val notificationBody: String,
    val enableMotion: Boolean,
    val enableLocation: Boolean,
    val enableNoise: Boolean,
    val enableDigitalUsage: Boolean,
    val sampleIntervalMinutes: Int,
)

data class AndroidBackgroundCaptureSnapshot(
    val isRunning: Boolean,
    val summary: String,
)

class AndroidBackgroundCaptureController(
    private val stateStore: AndroidBackgroundCaptureStateStore = InMemoryAndroidBackgroundCaptureStateStore(),
) {

    fun start(request: AndroidBackgroundCaptureRequest): AndroidBackgroundCaptureSnapshot {
        // 现阶段先把原生宿主的启停协议固定下来，
        // 后续接入真正的前台服务、WorkManager 与各类采集调度时可以直接沿用这层状态边界。
        val summary = buildSummary(request)
        stateStore.write(
            AndroidBackgroundCaptureState(
                activeRequest = request,
                lastSummary = summary,
            ),
        )
        return AndroidBackgroundCaptureSnapshot(isRunning = true, summary = summary)
    }

    fun refresh(): AndroidBackgroundCaptureSnapshot {
        val request = stateStore.read().activeRequest
        return if (request == null) {
            AndroidBackgroundCaptureSnapshot(
                isRunning = false,
                summary = stateStore.read().lastSummary,
            )
        } else {
            val summary = buildSummary(request)
            stateStore.write(
                stateStore.read().copy(
                    lastSummary = summary,
                ),
            )
            AndroidBackgroundCaptureSnapshot(
                isRunning = true,
                summary = summary,
            )
        }
    }

    fun stop(): AndroidBackgroundCaptureSnapshot {
        stateStore.write(
            stateStore.read().copy(
                activeRequest = null,
                lastSummary = "Android 后台采集已停止，后续不会继续沿用旧配置保活。",
            ),
        )
        return AndroidBackgroundCaptureSnapshot(
            isRunning = false,
            summary = stateStore.read().lastSummary,
        )
    }

    fun markError(message: String): AndroidBackgroundCaptureSnapshot {
        // 将最近一次错误保存在宿主侧，后续接真实前台服务时可以直接在调试页里解释恢复失败原因。
        stateStore.write(
            stateStore.read().copy(
                lastErrorMessage = message,
                lastSummary = "Android 后台采集出现异常：$message",
            ),
        )
        return AndroidBackgroundCaptureSnapshot(
            isRunning = false,
            summary = stateStore.read().lastSummary,
        )
    }

    fun snapshot(): AndroidBackgroundCaptureSnapshot {
        val request = stateStore.read().activeRequest
        return if (request == null) {
            AndroidBackgroundCaptureSnapshot(
                isRunning = false,
                summary = stateStore.read().lastSummary,
            )
        } else {
            AndroidBackgroundCaptureSnapshot(
                isRunning = true,
                summary = buildSummary(request),
            )
        }
    }

    fun currentRequest(): AndroidBackgroundCaptureRequest? {
        return stateStore.read().activeRequest
    }

    private fun buildSummary(request: AndroidBackgroundCaptureRequest): String {
        val enabledCapabilities = buildList<String> {
            if (request.enableMotion) {
                add("活动")
            }
            if (request.enableLocation) {
                add("位置")
            }
            if (request.enableNoise) {
                add("噪音")
            }
            if (request.enableDigitalUsage) {
                add("数字生活")
            }
        }

        val capabilitySummary = if (enabledCapabilities.isEmpty()) {
            "未启用具体采集能力"
        } else {
            enabledCapabilities.joinToString(separator = "、")
        }
        return "Android 后台采集已进入宿主骨架阶段，当前计划采集：$capabilitySummary；采样间隔 ${request.sampleIntervalMinutes} 分钟。"
    }
}
