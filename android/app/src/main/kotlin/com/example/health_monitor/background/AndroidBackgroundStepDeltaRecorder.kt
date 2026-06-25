package com.example.health_monitor.background

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import com.example.health_monitor.healthconnect.AndroidHealthConnectReader
import com.example.health_monitor.stepcounter.AndroidStepCounterReader
import java.util.Calendar

/**
 * Health Connect 不可用时，在后台按固定间隔记录计步器增量，供 Flutter 恢复前台后写入节奏轴。
 */
class AndroidBackgroundStepDeltaRecorder(
    private val context: Context,
    private val stepCounterReader: AndroidStepCounterReader,
    private val eventStore: AndroidBackgroundStepDeltaStore,
    private val healthConnectReader: AndroidHealthConnectReader,
    private val sharedPreferences: SharedPreferences,
    private val handler: Handler = Handler(Looper.getMainLooper()),
    private val nowMillis: () -> Long = { System.currentTimeMillis() },
) {
    private var started = false
    private var pollIntervalMillis: Long = DEFAULT_POLL_INTERVAL_MILLIS
    private val pollRunnable = object : Runnable {
        override fun run() {
            if (!started) {
                return
            }
            if (healthConnectReader.canReadHourlySteps()) {
                stop()
                return
            }
            recordDeltaIfNeeded()
            handler.postDelayed(this, pollIntervalMillis)
        }
    }

    fun start(pollIntervalMinutes: Int) {
        pollIntervalMillis = pollIntervalMinutes.coerceAtLeast(MIN_POLL_INTERVAL_MINUTES) * 60_000L
        if (healthConnectReader.canReadHourlySteps()) {
            stop()
            return
        }
        if (started) {
            handler.removeCallbacks(pollRunnable)
            handler.postDelayed(pollRunnable, pollIntervalMillis)
            return
        }
        started = true
        recordDeltaIfNeeded()
        handler.postDelayed(pollRunnable, pollIntervalMillis)
    }

    fun stop() {
        if (!started) {
            return
        }
        started = false
        handler.removeCallbacks(pollRunnable)
    }

    private fun recordDeltaIfNeeded() {
        val payload = stepCounterReader.readCurrent()
        if (!payload.isAvailable) {
            return
        }
        val now = nowMillis()
        val dayKey = dayKey(now)
        val lastDayKey = sharedPreferences.getString(KEY_LAST_DAY_KEY, null)
        var lastTotal = sharedPreferences.getInt(KEY_LAST_DAY_TOTAL, -1)
        if (lastDayKey != dayKey) {
            lastTotal = -1
        }
        if (lastTotal < 0) {
            sharedPreferences.edit()
                .putString(KEY_LAST_DAY_KEY, dayKey)
                .putInt(KEY_LAST_DAY_TOTAL, payload.stepCount)
                .apply()
            return
        }
        if (lastTotal == 0 && payload.stepCount >= COLD_START_SKIP_DELTA) {
            sharedPreferences.edit()
                .putString(KEY_LAST_DAY_KEY, dayKey)
                .putInt(KEY_LAST_DAY_TOTAL, payload.stepCount)
                .apply()
            return
        }
        val delta = payload.stepCount - lastTotal
        if (delta <= 0) {
            if (payload.stepCount < lastTotal) {
                sharedPreferences.edit()
                    .putInt(KEY_LAST_DAY_TOTAL, payload.stepCount)
                    .apply()
            }
            return
        }
        sharedPreferences.edit()
            .putString(KEY_LAST_DAY_KEY, dayKey)
            .putInt(KEY_LAST_DAY_TOTAL, payload.stepCount)
            .apply()
        eventStore.append(
            AndroidBackgroundStepDeltaEvent(
                eventId = "$dayKey-$now-$delta",
                capturedAtMillis = now,
                stepDelta = delta,
                dayStepTotal = payload.stepCount,
            ),
        )
    }

    private fun dayKey(epochMillis: Long): String {
        val calendar = Calendar.getInstance().apply {
            timeInMillis = epochMillis
        }
        val year = calendar.get(Calendar.YEAR).toString().padStart(4, '0')
        val month = (calendar.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        val day = calendar.get(Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        return "$year-$month-$day"
    }

    companion object {
        private const val KEY_LAST_DAY_KEY = "background_step_delta_last_day_key"
        private const val KEY_LAST_DAY_TOTAL = "background_step_delta_last_day_total"
        private const val MIN_POLL_INTERVAL_MINUTES = 5
        private const val DEFAULT_POLL_INTERVAL_MILLIS = 15 * 60_000L
        private const val COLD_START_SKIP_DELTA = 300
    }
}
