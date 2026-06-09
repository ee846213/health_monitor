package com.example.health_monitor

import com.example.health_monitor.background.AndroidBackgroundCaptureController
import com.example.health_monitor.background.AndroidBackgroundCaptureRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val backgroundCaptureController = AndroidBackgroundCaptureController()

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
        val snapshot = backgroundCaptureController.start(request)
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
            ),
        )
    }

    private fun handleStopBackgroundCapture(result: MethodChannel.Result) {
        val snapshot = backgroundCaptureController.stop()
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
            ),
        )
    }

    private fun handleGetBackgroundCaptureStatus(result: MethodChannel.Result) {
        val snapshot = backgroundCaptureController.snapshot()
        result.success(
            mapOf(
                "isRunning" to snapshot.isRunning,
                "summary" to snapshot.summary,
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
        private const val PLATFORM_BRIDGE_CHANNEL = "health_monitor/platform_bridge"
        private const val METHOD_START_BACKGROUND_CAPTURE = "android.background.start"
        private const val METHOD_STOP_BACKGROUND_CAPTURE = "android.background.stop"
        private const val METHOD_GET_BACKGROUND_CAPTURE_STATUS = "android.background.status"
    }
}
