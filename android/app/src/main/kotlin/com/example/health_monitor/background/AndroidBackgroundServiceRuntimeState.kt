package com.example.health_monitor.background

/**
 * 记录当前进程内前台服务的真实生命周期状态。
 *
 * SharedPreferences 中的 activeRequest 只代表用户希望后台采集继续运行，
 * 不能证明 Android Service 仍然存活。应用进程重新创建后，本对象会恢复为 false，
 * 此时 Flutter 启动协调器会重新拉起服务，避免陈旧持久化状态阻断自动恢复。
 */
object AndroidBackgroundServiceRuntimeState {
    @Volatile
    var isServiceRunning: Boolean = false
        private set

    fun markStarted() {
        isServiceRunning = true
    }

    fun markStopped() {
        isServiceRunning = false
    }
}

fun AndroidBackgroundSchedulerSnapshot.withRuntimeServiceState(
    serviceRunning: Boolean,
): AndroidBackgroundSchedulerSnapshot {
    if (!isRunning || serviceRunning) {
        return this
    }

    return copy(
        isRunning = false,
        summary = "Android 后台采集配置仍然有效，但前台服务当前未运行，应用将尝试自动恢复。",
    )
}
