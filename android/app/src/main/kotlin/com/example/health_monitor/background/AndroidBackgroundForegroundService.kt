package com.example.health_monitor.background

import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import com.example.health_monitor.stepcounter.AndroidStepCounterReader
import com.example.health_monitor.usagestats.AndroidUsageStatsReader
import com.example.health_monitor.usagestats.SharedPreferencesAndroidUsageSummarySnapshotStore

class AndroidBackgroundForegroundService : Service() {
    private val intentFactory = AndroidBackgroundForegroundServiceIntentFactory()
    private val stateStore by lazy {
        SharedPreferencesAndroidBackgroundCaptureStateStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }
    private val controller by lazy {
        AndroidBackgroundCaptureController(stateStore)
    }
    private val scheduler by lazy {
        AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(controller),
            stateStore = stateStore,
        )
    }
    private val orchestrator by lazy {
        AndroidForegroundServiceOrchestrator(scheduler)
    }
    private val runtime by lazy {
        AndroidBackgroundCaptureRuntime(orchestrator)
    }
    private val host by lazy {
        AndroidBackgroundForegroundServiceHost(
            AndroidSystemNotificationGateway(
                context = this,
                notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager,
            ),
        )
    }
    private val stepCounterReader by lazy {
        AndroidStepCounterReader(this)
    }
    private val walkingScreenRiskEventStore by lazy {
        SharedPreferencesAndroidWalkingScreenRiskEventStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }
    private val walkingScreenRiskMonitor by lazy {
        AndroidWalkingScreenRiskMonitor(
            context = this,
            stepCounterReader = stepCounterReader,
            eventStore = walkingScreenRiskEventStore,
        )
    }
    private val usageStatsReader by lazy {
        AndroidUsageStatsReader(this)
    }
    private val usageSummarySnapshotStore by lazy {
        SharedPreferencesAndroidUsageSummarySnapshotStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_START
        when (action) {
            AndroidBackgroundForegroundServiceIntentFactory.ACTION_START -> {
                val request = intentFactory.parseRequest(intent)
                if (request == null) {
                    stopSelf(startId)
                    return START_NOT_STICKY
                }
                stepCounterReader.startListening()
                if (request.enableMotion && request.enableDigitalUsage) {
                    walkingScreenRiskMonitor.start()
                }
                if (request.enableDigitalUsage) {
                    usageStatsReader.readDailySummary()?.let(usageSummarySnapshotStore::enqueue)
                }
                val snapshot = runtime.start(request)
                runAsForeground(snapshot.notification)
                return START_STICKY
            }

            AndroidBackgroundForegroundServiceIntentFactory.ACTION_STOP -> {
                walkingScreenRiskMonitor.stop()
                stepCounterReader.stopListening()
                runtime.stop()
                stopForeground(true)
                stopSelf(startId)
                return START_NOT_STICKY
            }

            AndroidBackgroundForegroundServiceIntentFactory.ACTION_REFRESH -> {
                scheduler.currentRequest()?.takeIf { it.enableDigitalUsage }?.let {
                    usageStatsReader.readDailySummary()?.let(usageSummarySnapshotStore::enqueue)
                }
                val snapshot = runtime.refresh()
                runAsForeground(snapshot.notification)
                return START_STICKY
            }

            else -> {
                scheduler.currentRequest()?.takeIf { it.enableDigitalUsage }?.let {
                    usageStatsReader.readDailySummary()?.let(usageSummarySnapshotStore::enqueue)
                }
                val snapshot = runtime.refresh()
                runAsForeground(snapshot.notification)
                return START_STICKY
            }
        }
    }

    override fun onDestroy() {
        walkingScreenRiskMonitor.stop()
        stepCounterReader.stopListening()
        super.onDestroy()
    }

    private fun runAsForeground(notification: AndroidBackgroundNotification) {
        val systemNotification = host.createNotification(notification)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                FOREGROUND_NOTIFICATION_ID,
                systemNotification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC,
            )
        } else {
            startForeground(FOREGROUND_NOTIFICATION_ID, systemNotification)
        }
    }

    companion object {
        private const val ACTION_START = AndroidBackgroundForegroundServiceIntentFactory.ACTION_START
        private const val PREFS_NAME = "health_monitor_background_state"
        private const val FOREGROUND_NOTIFICATION_ID = 1001
    }
}
