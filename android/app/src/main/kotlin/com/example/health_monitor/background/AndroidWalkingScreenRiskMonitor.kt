package com.example.health_monitor.background

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import com.example.health_monitor.stepcounter.AndroidStepCounterReader

class AndroidWalkingScreenRiskMonitor(
    private val context: Context,
    private val stepCounterReader: AndroidStepCounterReader,
    private val eventStore: AndroidWalkingScreenRiskEventStore,
    private val detector: AndroidWalkingScreenRiskDetector = AndroidWalkingScreenRiskDetector(),
    private val onRiskDetected: (AndroidWalkingScreenRiskEvent) -> Boolean = { false },
    private val handler: Handler = Handler(Looper.getMainLooper()),
    private val nowMillis: () -> Long = { System.currentTimeMillis() },
) {
    private var started = false
    private val pollRunnable = object : Runnable {
        override fun run() {
            if (!started) {
                return
            }

            val payload = stepCounterReader.readCurrent()
            if (payload.isAvailable) {
                val event = detector.poll(
                    // 计步器是 on-change 传感器，未产生新步数时 capturedAt 可能保持不变。
                    // 风险持续时间必须使用当前墙钟时间，不能依赖最后一次传感器时间戳。
                    nowMillis = nowMillis(),
                    currentStepCount = payload.stepCount,
                )
                if (event != null) {
                    val delivered = onRiskDetected(event)
                    eventStore.append(
                        event.copy(notificationDelivered = delivered),
                    )
                }
            }
            handler.postDelayed(this, POLL_INTERVAL_MILLIS)
        }
    }
    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_ON,
                Intent.ACTION_USER_PRESENT,
                Intent.ACTION_USER_UNLOCKED -> detector.onScreenTurnedOn(nowMillis())
                Intent.ACTION_SCREEN_OFF -> detector.onScreenTurnedOff()
            }
        }
    }

    fun start() {
        if (started) {
            return
        }
        started = true
        registerReceiver()
        syncInitialScreenState()
        handler.post(pollRunnable)
    }

    fun stop() {
        if (!started) {
            return
        }
        started = false
        runCatching {
            context.unregisterReceiver(screenReceiver)
        }
        handler.removeCallbacks(pollRunnable)
        detector.onScreenTurnedOff()
    }

    private fun registerReceiver() {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
            addAction(Intent.ACTION_USER_UNLOCKED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(
                screenReceiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED,
            )
        } else {
            context.registerReceiver(screenReceiver, filter)
        }
    }

    private fun syncInitialScreenState() {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val isInteractive = powerManager?.isInteractive == true
        if (isInteractive) {
            detector.onScreenTurnedOn(nowMillis())
        } else {
            detector.onScreenTurnedOff()
        }
    }

    companion object {
        private const val POLL_INTERVAL_MILLIS = 1000L
    }
}
