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
        val snapshot = AndroidBackgroundCaptureWorker(scheduler).runOnce()
        return Result.success()
    }

    companion object {
        private const val PREFS_NAME = "health_monitor_background_state"
    }
}
