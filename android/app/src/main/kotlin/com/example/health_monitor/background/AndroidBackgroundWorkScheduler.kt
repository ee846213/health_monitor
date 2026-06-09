package com.example.health_monitor.background

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

class AndroidBackgroundWorkScheduler(
    private val worker: AndroidBackgroundCaptureWorker,
    private val workManager: WorkManager? = null,
) {
    fun scheduleOnce(): AndroidBackgroundSchedulerSnapshot {
        // 业务层仍然保留单次运行入口，既用于调试，也作为 WorkManager 执行失败后的降级路径。
        return worker.runOnce()
    }

    fun enqueueRefresh(context: Context): Unit {
        val manager = workManager ?: WorkManager.getInstance(context)
        val request = OneTimeWorkRequestBuilder<AndroidBackgroundWorkManagerWorker>()
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                    .build(),
            )
            .build()
        manager.enqueueUniqueWork(
            UNIQUE_REFRESH_WORK_NAME,
            ExistingWorkPolicy.REPLACE,
            request,
        )
    }

    fun enqueuePeriodic(context: Context, intervalMinutes: Long): Unit {
        val manager = workManager ?: WorkManager.getInstance(context)
        val request = PeriodicWorkRequestBuilder<AndroidBackgroundWorkManagerWorker>(
            intervalMinutes.coerceAtLeast(MIN_PERIODIC_MINUTES),
            TimeUnit.MINUTES,
        )
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.NOT_REQUIRED)
                    .build(),
            )
            .build()
        manager.enqueueUniquePeriodicWork(
            UNIQUE_PERIODIC_WORK_NAME,
            ExistingPeriodicWorkPolicy.REPLACE,
            request,
        )
    }

    fun cancelAll(context: Context): Unit {
        val manager = workManager ?: WorkManager.getInstance(context)
        manager.cancelUniqueWork(UNIQUE_REFRESH_WORK_NAME)
        manager.cancelUniqueWork(UNIQUE_PERIODIC_WORK_NAME)
    }

    companion object {
        private const val MIN_PERIODIC_MINUTES = 15L
        private const val UNIQUE_REFRESH_WORK_NAME = "health_monitor.background.refresh"
        private const val UNIQUE_PERIODIC_WORK_NAME = "health_monitor.background.periodic"
    }
}
