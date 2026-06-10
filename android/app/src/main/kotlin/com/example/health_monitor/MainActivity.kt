package com.example.health_monitor

import com.example.health_monitor.background.AndroidBackgroundCaptureController
import com.example.health_monitor.background.AndroidBackgroundCaptureExecutor
import com.example.health_monitor.background.AndroidBackgroundCaptureRequest
import com.example.health_monitor.background.AndroidBackgroundCaptureScheduler
import com.example.health_monitor.background.AndroidBackgroundCaptureRuntime
import com.example.health_monitor.background.SharedPreferencesAndroidBackgroundCaptureStateStore
import com.example.health_monitor.background.AndroidForegroundServiceOrchestrator
import com.example.health_monitor.background.AndroidBackgroundForegroundServiceIntentFactory
import com.example.health_monitor.background.AndroidBackgroundWorkScheduler
import android.content.Intent
import androidx.core.content.ContextCompat
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val backgroundCaptureStateStore by lazy {
        SharedPreferencesAndroidBackgroundCaptureStateStore(
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE),
        )
    }
    private val backgroundCaptureController = AndroidBackgroundCaptureController(
        stateStore = backgroundCaptureStateStore,
    )
    private val backgroundCaptureScheduler = AndroidBackgroundCaptureScheduler(
        executor = AndroidBackgroundCaptureExecutor(
            controller = backgroundCaptureController,
        ),
        stateStore = backgroundCaptureStateStore,
    )
    private val foregroundServiceOrchestrator = AndroidForegroundServiceOrchestrator(
        backgroundCaptureScheduler,
    )
    private val backgroundWorkScheduler = AndroidBackgroundWorkScheduler(
        com.example.health_monitor.background.AndroidBackgroundCaptureWorker(backgroundCaptureScheduler),
    )
    private val backgroundCaptureRuntime = AndroidBackgroundCaptureRuntime(
        foregroundServiceOrchestrator,
    )
    private val foregroundServiceIntentFactory = AndroidBackgroundForegroundServiceIntentFactory()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
        val snapshot = backgroundCaptureScheduler.snapshot()
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
        private const val METHOD_START_BACKGROUND_CAPTURE = "android.background.start"
        private const val METHOD_STOP_BACKGROUND_CAPTURE = "android.background.stop"
        private const val METHOD_GET_BACKGROUND_CAPTURE_STATUS = "android.background.status"
        private const val METHOD_MARK_BACKGROUND_CAPTURE_ERROR = "android.background.error"
        private const val METHOD_REFRESH_BACKGROUND_CAPTURE = "android.background.refresh"
    }
}
