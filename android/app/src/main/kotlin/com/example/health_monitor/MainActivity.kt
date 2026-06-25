package com.example.health_monitor

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import com.example.health_monitor.background.AndroidReminderPolicySnapshot
import com.example.health_monitor.background.AndroidReminderPolicyStore
import com.example.health_monitor.background.AndroidBackgroundCaptureController
import com.example.health_monitor.background.AndroidBackgroundCaptureExecutor
import com.example.health_monitor.background.AndroidBackgroundCaptureRequest
import com.example.health_monitor.background.AndroidBackgroundCaptureRuntime
import com.example.health_monitor.background.AndroidBackgroundCaptureScheduler
import com.example.health_monitor.background.AndroidBackgroundForegroundServiceIntentFactory
import com.example.health_monitor.background.AndroidBackgroundServiceRuntimeState
import com.example.health_monitor.background.AndroidBackgroundWorkScheduler
import com.example.health_monitor.background.AndroidForegroundServiceOrchestrator
import com.example.health_monitor.background.SharedPreferencesAndroidBackgroundStepDeltaStore
import com.example.health_monitor.background.SharedPreferencesAndroidBackgroundCaptureStateStore
import com.example.health_monitor.background.toChannelMap
import com.example.health_monitor.background.withRuntimeServiceState
import com.example.health_monitor.light.AndroidAmbientLightStreamHandler
import com.example.health_monitor.stepcounter.AndroidStepCounterReader
import com.example.health_monitor.stepcounter.StepCounterPayload
import com.example.health_monitor.usagestats.AndroidUsageStatsReader
import com.example.health_monitor.usagestats.SharedPreferencesAndroidUsageSummarySnapshotStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val backgroundCaptureStateStore by lazy {
        SharedPreferencesAndroidBackgroundCaptureStateStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }
    private val backgroundCaptureController by lazy {
        AndroidBackgroundCaptureController(
            stateStore = backgroundCaptureStateStore,
        )
    }
    private val backgroundCaptureScheduler by lazy {
        AndroidBackgroundCaptureScheduler(
            executor = AndroidBackgroundCaptureExecutor(
                controller = backgroundCaptureController,
            ),
            stateStore = backgroundCaptureStateStore,
        )
    }
    private val foregroundServiceOrchestrator by lazy {
        AndroidForegroundServiceOrchestrator(
            backgroundCaptureScheduler,
        )
    }
    private val backgroundWorkScheduler by lazy {
        AndroidBackgroundWorkScheduler(
            com.example.health_monitor.background.AndroidBackgroundCaptureWorker(backgroundCaptureScheduler),
        )
    }
    private val backgroundCaptureRuntime by lazy {
        AndroidBackgroundCaptureRuntime(
            foregroundServiceOrchestrator,
        )
    }
    private val foregroundServiceIntentFactory by lazy {
        AndroidBackgroundForegroundServiceIntentFactory()
    }
    private val stepCounterReader by lazy {
        AndroidStepCounterReader(this)
    }
    private val walkingScreenRiskEventStore by lazy {
        com.example.health_monitor.background.SharedPreferencesAndroidWalkingScreenRiskEventStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
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
    private val ambientLightStreamHandler by lazy {
        AndroidAmbientLightStreamHandler(this)
    }
    private val reminderPolicyStore by lazy {
        AndroidReminderPolicyStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LIGHT_SAMPLES_CHANNEL,
        ).setStreamHandler(ambientLightStreamHandler)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PLATFORM_BRIDGE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_START_BACKGROUND_CAPTURE -> handleStartBackgroundCapture(call, result)
                METHOD_STOP_BACKGROUND_CAPTURE -> handleStopBackgroundCapture(result)
                METHOD_GET_BACKGROUND_CAPTURE_STATUS -> handleGetBackgroundCaptureStatus(result)
                METHOD_MARK_BACKGROUND_CAPTURE_ERROR -> handleMarkBackgroundCaptureError(call, result)
                METHOD_REFRESH_BACKGROUND_CAPTURE -> handleRefreshBackgroundCapture(result)
                METHOD_HAS_USAGE_ACCESS -> handleHasUsageAccess(result)
                METHOD_OPEN_USAGE_ACCESS_SETTINGS -> handleOpenUsageAccessSettings(result)
                METHOD_GET_USAGE_CAPABILITY_STATUS -> handleGetUsageCapabilityStatus(result)
                METHOD_READ_DAILY_USAGE_SUMMARY -> handleReadDailyUsageSummary(call, result)
                METHOD_READ_RANGE_USAGE_SUMMARIES -> handleReadRangeUsageSummaries(call, result)
                METHOD_DRAIN_PENDING_USAGE_SUMMARIES -> handleDrainPendingUsageSummaries(result)
                METHOD_GET_STEP_COUNTER -> handleGetStepCounter(result)
                METHOD_DRAIN_BACKGROUND_STEP_DELTAS -> handleDrainBackgroundStepDeltas(result)
                METHOD_DRAIN_WALKING_SCREEN_RISK_EVENTS -> handleDrainWalkingScreenRiskEvents(result)
                METHOD_UPDATE_REMINDER_POLICY -> handleUpdateReminderPolicy(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleStartBackgroundCapture(call: MethodCall, result: MethodChannel.Result) {
        val request = parseRequest(call)
            ?: run {
                result.error(
                    "invalid_args",
                    "Android 后台采集启动参数不完整，无法建立宿主侧后台链路。",
                    null,
                )
                return
            }
        ContextCompat.startForegroundService(this, foregroundServiceIntentFactory.createStartIntent(this, request))
        backgroundWorkScheduler.enqueuePeriodic(this, request.sampleIntervalMinutes.toLong())
        val snapshot = backgroundCaptureRuntime.start(request)
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
                "lastErrorMessage" to snapshot.lastErrorMessage,
            ),
        )
    }

    private fun handleStopBackgroundCapture(result: MethodChannel.Result) {
        startService(foregroundServiceIntentFactory.createStopIntent(this))
        backgroundWorkScheduler.cancelAll(this)
        val snapshot = backgroundCaptureRuntime.stop()
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
                "lastErrorMessage" to snapshot.lastErrorMessage,
            ),
        )
    }

    private fun handleGetBackgroundCaptureStatus(result: MethodChannel.Result) {
        val snapshot = backgroundCaptureScheduler.snapshot().withRuntimeServiceState(
            AndroidBackgroundServiceRuntimeState.isServiceRunning,
        )
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
                "lastErrorMessage" to snapshot.lastErrorMessage,
            ),
        )
    }

    private fun handleMarkBackgroundCaptureError(call: MethodCall, result: MethodChannel.Result) {
        val message = call.argument<String>("message")
            ?: "Android 后台采集进入异常状态，但未提供错误详情。"
        val snapshot = backgroundCaptureRuntime.recover(message)
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
                "lastErrorMessage" to snapshot.lastErrorMessage,
            ),
        )
    }

    private fun handleRefreshBackgroundCapture(result: MethodChannel.Result) {
        ContextCompat.startForegroundService(this, foregroundServiceIntentFactory.createRefreshIntent(this))
        backgroundWorkScheduler.enqueueRefresh(this)
        val snapshot = backgroundCaptureRuntime.refresh()
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
                "lastErrorMessage" to snapshot.lastErrorMessage,
                "notificationTitle" to snapshot.notification.title,
                "notificationBody" to snapshot.notification.body,
                "notificationChannelId" to snapshot.notification.channelId,
            ),
        )
    }

    private fun handleHasUsageAccess(result: MethodChannel.Result) {
        result.success(hasUsageAccess())
    }

    private fun handleOpenUsageAccessSettings(result: MethodChannel.Result) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    private fun handleGetUsageCapabilityStatus(result: MethodChannel.Result) {
        result.success(usageStatsReader.getCapabilityStatus().toChannelMap())
    }

    private fun handleReadDailyUsageSummary(call: MethodCall, result: MethodChannel.Result) {
        val referenceTimeMillis = call.argument<Long>("referenceTimeMillis")
            ?: System.currentTimeMillis()
        result.success(
            usageStatsReader.readDailySummary(referenceTimeMillis)?.toChannelMap(),
        )
    }

    private fun handleReadRangeUsageSummaries(call: MethodCall, result: MethodChannel.Result) {
        val startMillis = call.argument<Long>("startMillis") ?: run {
            result.success(emptyList<Map<String, Any>>())
            return
        }
        val endMillis = call.argument<Long>("endMillis") ?: run {
            result.success(emptyList<Map<String, Any>>())
            return
        }
        result.success(
            usageStatsReader.readRangeSummaries(startMillis, endMillis)
                .map { item -> item.toChannelMap() },
        )
    }

    private fun handleDrainPendingUsageSummaries(result: MethodChannel.Result) {
        result.success(
            usageSummarySnapshotStore.drain().map { item -> item.toChannelMap() },
        )
    }

    private fun handleGetStepCounter(result: MethodChannel.Result) {
        val payload = stepCounterReader.startListening()
        result.success(payload.toChannelMap())
    }

    private fun handleDrainBackgroundStepDeltas(result: MethodChannel.Result) {
        val payload = SharedPreferencesAndroidBackgroundStepDeltaStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        ).drain().map { event -> event.toChannelMap() }
        result.success(payload)
    }

    private fun handleDrainWalkingScreenRiskEvents(result: MethodChannel.Result) {
        val payload = walkingScreenRiskEventStore.drain()
            .map { event -> event.toChannelMap() }
        result.success(payload)
    }

    private fun handleUpdateReminderPolicy(call: MethodCall, result: MethodChannel.Result) {
        val masterEnabled = call.argument<Boolean>("masterEnabled") ?: true
        val walkingScreenEnabled = call.argument<Boolean>("walkingScreenEnabled") ?: true
        val dndEnabled = call.argument<Boolean>("dndEnabled") ?: false
        val dndStartMinutes = call.argument<Int>("dndStartMinutes") ?: 0
        val dndEndMinutes = call.argument<Int>("dndEndMinutes") ?: 0
        reminderPolicyStore.update(
            AndroidReminderPolicySnapshot(
                masterEnabled = masterEnabled,
                walkingScreenEnabled = walkingScreenEnabled,
                dndEnabled = dndEnabled,
                dndStartMinutes = dndStartMinutes,
                dndEndMinutes = dndEndMinutes,
            ),
        )
        result.success(true)
    }

    private fun hasUsageAccess(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return false
        }

        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOpsManager.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun parseRequest(call: MethodCall): AndroidBackgroundCaptureRequest? {
        val notificationTitle = call.argument<String>("notificationTitle") ?: return null
        val notificationBody = call.argument<String>("notificationBody") ?: return null
        val enableMotion = call.argument<Boolean>("enableMotion") ?: return null
        val enableLocation = call.argument<Boolean>("enableLocation") ?: return null
        val enableNoise = call.argument<Boolean>("enableNoise") ?: return null
        val enableDigitalUsage = call.argument<Boolean>("enableDigitalUsage") ?: return null
        val sampleIntervalMinutes = call.argument<Int>("sampleIntervalMinutes") ?: return null

        return AndroidBackgroundCaptureRequest(
            notificationTitle = notificationTitle,
            notificationBody = notificationBody,
            enableMotion = enableMotion,
            enableLocation = enableLocation,
            enableNoise = enableNoise,
            enableDigitalUsage = enableDigitalUsage,
            sampleIntervalMinutes = sampleIntervalMinutes,
        )
    }

    companion object {
        private const val PREFS_NAME = "health_monitor_background_state"
        private const val PLATFORM_BRIDGE_CHANNEL = "health_monitor/platform_bridge"
        private const val LIGHT_SAMPLES_CHANNEL = "health_monitor/light_samples"
        private const val METHOD_START_BACKGROUND_CAPTURE = "android.background.start"
        private const val METHOD_STOP_BACKGROUND_CAPTURE = "android.background.stop"
        private const val METHOD_GET_BACKGROUND_CAPTURE_STATUS = "android.background.status"
        private const val METHOD_MARK_BACKGROUND_CAPTURE_ERROR = "android.background.error"
        private const val METHOD_REFRESH_BACKGROUND_CAPTURE = "android.background.refresh"
        private const val METHOD_HAS_USAGE_ACCESS = "android.permissions.hasUsageAccess"
        private const val METHOD_OPEN_USAGE_ACCESS_SETTINGS =
            "android.permissions.openUsageAccessSettings"
        private const val METHOD_GET_USAGE_CAPABILITY_STATUS =
            "android.usage.getCapabilityStatus"
        private const val METHOD_READ_DAILY_USAGE_SUMMARY =
            "android.usage.readDailySummary"
        private const val METHOD_READ_RANGE_USAGE_SUMMARIES =
            "android.usage.readRangeSummaries"
        private const val METHOD_DRAIN_PENDING_USAGE_SUMMARIES =
            "android.usage.drainPendingSummaries"
        private const val METHOD_GET_STEP_COUNTER = "android.steps.current"
        private const val METHOD_DRAIN_BACKGROUND_STEP_DELTAS =
            "android.steps.drainBackgroundDeltas"
        private const val METHOD_DRAIN_WALKING_SCREEN_RISK_EVENTS =
            "android.riskEvents.drainWalkingScreenRisks"
        private const val METHOD_UPDATE_REMINDER_POLICY = "android.reminder.updatePolicy"
    }
}

private fun StepCounterPayload.toChannelMap(): Map<String, Any?> {
    return mapOf(
        "capturedAtMillis" to capturedAtMillis,
        "stepCount" to stepCount,
        "isAvailable" to isAvailable,
        "reason" to reason,
    )
}
