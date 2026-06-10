package com.example.health_monitor.background

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class AndroidBackgroundWorkManagerWorker(
    appContext: Context,
    params: WorkerParameters,
) : Worker(appContext, params) {
    override fun doWork(): Result {
        // 周期任务到点时只做宿主侧刷新，不让后台任务依赖 Flutter 引擎常驻。
        val stateStore = SharedPreferencesAndroidBackgroundCaptureStateStore(
            applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
        val controller = AndroidBackgroundCaptureController(stateStore)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = stateStore,
        )
        return try {
            AndroidBackgroundWorkManagerJob(scheduler).runOnce()
            // 正常路径下只要把状态刷新回共享仓即可，交给调试页和下一次调度读取。
            Result.success()
        } catch (error: Throwable) {
            // Worker 层发生异常时，先把异常写回共享状态，再让 WorkManager 决定是否重试。
            scheduler.markError(error.message ?: "Android 后台 WorkManager 执行失败。")
            Result.retry()
        }
    }

    companion object {
        private const val PREFS_NAME = "health_monitor_background_state"
    }
}
