package com.example.health_monitor.background

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.example.health_monitor.usagestats.AndroidUsageStatsReader
import com.example.health_monitor.usagestats.SharedPreferencesAndroidUsageSummarySnapshotStore

class AndroidBackgroundWorkManagerWorker(
    appContext: Context,
    params: WorkerParameters,
) : Worker(appContext, params) {
    override fun doWork(): Result {
        val stateStore = SharedPreferencesAndroidBackgroundCaptureStateStore(
            applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
        val controller = AndroidBackgroundCaptureController(stateStore)
        val scheduler = AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = stateStore,
        )
        val usageStatsReader = AndroidUsageStatsReader(applicationContext)
        val usageSummarySnapshotStore = SharedPreferencesAndroidUsageSummarySnapshotStore(
            applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )

        return try {
            AndroidBackgroundWorkManagerJob(scheduler).runOnce()
            stateStore.read().activeRequest
                ?.takeIf { it.enableDigitalUsage }
                ?.let {
                    usageStatsReader.readDailySummary()?.let(usageSummarySnapshotStore::enqueue)
                }
            Result.success()
        } catch (error: Throwable) {
            scheduler.markError(error.message ?: "Android 后台 WorkManager 执行失败。")
            Result.retry()
        }
    }

    companion object {
        private const val PREFS_NAME = "health_monitor_background_state"
    }
}
