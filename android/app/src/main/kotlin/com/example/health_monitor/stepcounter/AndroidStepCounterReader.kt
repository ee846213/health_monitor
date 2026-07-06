package com.example.health_monitor.stepcounter

import android.Manifest
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import java.time.LocalDate
import java.time.ZoneId
import java.util.Calendar
import java.util.concurrent.atomic.AtomicBoolean
import org.json.JSONObject

class AndroidStepCounterReader(
    private val context: Context,
) {
    private val stateStore = StepCounterStateStore(context)
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private val stepCounterSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

    fun readCurrent(): StepCounterPayload {
        return stateStore.read() ?: unavailable("step_counter_warming_up")
    }

    fun startListening(): StepCounterPayload {
        if (!hasActivityRecognitionPermission()) {
            return unavailable("activity_recognition_permission_denied")
        }
        val manager = sensorManager ?: return unavailable("sensor_manager_unavailable")
        val sensor = stepCounterSensor ?: return unavailable("step_counter_sensor_unavailable")
        stateStore.ensureListening(manager, sensor)
        return stateStore.read() ?: unavailable("step_counter_warming_up")
    }

    fun stopListening() {
        val manager = sensorManager ?: return
        stateStore.stopListening(manager)
    }

    fun readHistoricalDays(maxDays: Int = DEFAULT_HISTORY_DAYS): List<StepCounterDayPayload> {
        return stateStore.readHistoricalDays(maxDays)
    }

    private fun unavailable(reason: String): StepCounterPayload {
        return StepCounterPayload(
            capturedAtMillis = System.currentTimeMillis(),
            stepCount = 0,
            isAvailable = false,
            reason = reason,
        )
    }

    private fun hasActivityRecognitionPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return true
        }
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
    }

    companion object {
        private const val DEFAULT_HISTORY_DAYS = 30
    }
}

private class StepCounterStateStore(
    context: Context,
) : SensorEventListener {
    private val sharedPreferences: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val listenerStarted = AtomicBoolean(false)

    fun ensureListening(
        sensorManager: SensorManager,
        sensor: Sensor,
    ) {
        if (!listenerStarted.compareAndSet(false, true)) {
            return
        }
        if (!sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)) {
            listenerStarted.set(false)
        }
    }

    fun stopListening(sensorManager: SensorManager) {
        if (listenerStarted.compareAndSet(true, false)) {
            sensorManager.unregisterListener(this)
        }
    }

    fun read(): StepCounterPayload? {
        val state = readState() ?: return null
        val todayKey = dayKey(System.currentTimeMillis())
        if (state.dayKey != todayKey) {
          persistDaySnapshot(state)
          return StepCounterPayload(
              capturedAtMillis = System.currentTimeMillis(),
              stepCount = 0,
              isAvailable = true,
          )
        }
        return StepCounterPayload(
            capturedAtMillis = state.capturedAtMillis,
            stepCount = state.stepCount,
            isAvailable = true,
        )
    }

    private fun readState(): StepCounterState? {
        val dayKey = sharedPreferences.getString(KEY_DAY_KEY, null) ?: return null
        val stepCount = sharedPreferences.getInt(KEY_STEP_COUNT, -1)
        val capturedAtMillis = sharedPreferences.getLong(KEY_CAPTURED_AT, 0L)
        val dayStartRaw = sharedPreferences.getFloat(KEY_DAY_START_RAW, -1f)
        val lastRaw = sharedPreferences.getFloat(KEY_LAST_RAW, -1f)
        if (stepCount < 0 || dayStartRaw < 0f || lastRaw < 0f) {
            return null
        }
        return StepCounterState(
            dayKey = dayKey,
            capturedAtMillis = capturedAtMillis,
            stepCount = stepCount,
            dayStartRaw = dayStartRaw.toDouble(),
            lastRaw = lastRaw.toDouble(),
        )
    }

    fun readHistoricalDays(maxDays: Int): List<StepCounterDayPayload> {
        val state = readState()
        if (state != null) {
            persistDaySnapshot(state)
            recoverMissedPreviousDaySnapshot(state.dayKey, state.dayStartRaw)
        }
        return readHistory()
            .values
            .sortedByDescending { it.dayKey }
            .take(maxDays.coerceAtLeast(1))
            .map {
                StepCounterDayPayload(
                    dayKey = it.dayKey,
                    capturedAtMillis = it.capturedAtMillis,
                    stepCount = it.stepCount,
                )
            }
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_STEP_COUNTER) {
            return
        }

        val now = System.currentTimeMillis()
        val nowDayKey = dayKey(now)
        val rawTotal = event.values.firstOrNull()?.toDouble() ?: return
        val currentDayKey = sharedPreferences.getString(KEY_DAY_KEY, null)
        val currentState = readState()
        val nextState = when {
            currentDayKey != nowDayKey || currentState == null -> {
                if (currentState != null) {
                    persistDaySnapshot(currentState)
                    recoverMissedPreviousDaySnapshot(nowDayKey, rawTotal)
                }
                StepCounterState(
                    dayKey = nowDayKey,
                    capturedAtMillis = now,
                    stepCount = 0,
                    dayStartRaw = rawTotal,
                    lastRaw = rawTotal,
                )
            }

            rawTotal < currentState.lastRaw -> {
                persistDaySnapshot(currentState)
                StepCounterState(
                    dayKey = nowDayKey,
                    capturedAtMillis = now,
                    stepCount = 0,
                    dayStartRaw = rawTotal,
                    lastRaw = rawTotal,
                )
            }

            else -> {
                val daySteps = (rawTotal - currentState.dayStartRaw).toInt().coerceAtLeast(0)
                StepCounterState(
                    dayKey = nowDayKey,
                    capturedAtMillis = now,
                    stepCount = daySteps,
                    dayStartRaw = currentState.dayStartRaw,
                    lastRaw = rawTotal,
                )
            }
        }

        writeCurrentState(nextState)
        persistDaySnapshot(nextState)
    }

    private fun writeCurrentState(state: StepCounterState) {
        sharedPreferences.edit()
            .putString(KEY_DAY_KEY, state.dayKey)
            .putInt(KEY_STEP_COUNT, state.stepCount)
            .putFloat(KEY_DAY_START_RAW, state.dayStartRaw.toFloat())
            .putFloat(KEY_LAST_RAW, state.lastRaw.toFloat())
            .putLong(KEY_CAPTURED_AT, state.capturedAtMillis)
            .apply()
    }

    private fun persistDaySnapshot(state: StepCounterState) {
        val history = readHistory()
        val existing = history[state.dayKey]
        if (existing == null ||
            state.stepCount > existing.stepCount ||
            (state.stepCount == existing.stepCount &&
                state.capturedAtMillis >= existing.capturedAtMillis)
        ) {
            history[state.dayKey] = state
        }
        writeHistory(history)
    }

    private fun recoverMissedPreviousDaySnapshot(
        currentDayKey: String,
        currentDayStartRaw: Double,
    ) {
        val history = readHistory()
        val recovered = recoverMissedPreviousDaySnapshot(
            currentDayKey = currentDayKey,
            currentDayStartRaw = currentDayStartRaw,
            history = history.values.map { state ->
                StepCounterHistorySnapshot(
                    dayKey = state.dayKey,
                    capturedAtMillis = state.capturedAtMillis,
                    stepCount = state.stepCount,
                    dayStartRaw = state.dayStartRaw,
                    lastRaw = state.lastRaw,
                )
            },
        ) ?: return
        val existing = history[recovered.dayKey]
        if (existing != null && existing.stepCount >= recovered.stepCount) {
            return
        }
        // Health Connect 在部分机型上可能已授权但聚合为空。跨日后首次收到
        // TYPE_STEP_COUNTER raw total 时，用 raw 差值为缺失的前一日补一个降级快照，
        // 避免昨天在每日指标里彻底消失。
        history[recovered.dayKey] = StepCounterState(
            dayKey = recovered.dayKey,
            capturedAtMillis = recovered.capturedAtMillis,
            stepCount = recovered.stepCount,
            dayStartRaw = recovered.dayStartRaw,
            lastRaw = recovered.lastRaw,
        )
        writeHistory(history)
    }

    private fun readHistory(): MutableMap<String, StepCounterState> {
        val raw = sharedPreferences.getString(KEY_DAILY_HISTORY, null)
            ?: return mutableMapOf()
        val root = runCatching { JSONObject(raw) }.getOrElse { JSONObject() }
        val result = mutableMapOf<String, StepCounterState>()
        val keys = root.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val item = root.optJSONObject(key) ?: continue
            val stepCount = item.optInt(KEY_STEP_COUNT, -1)
            val capturedAtMillis = item.optLong(KEY_CAPTURED_AT, 0L)
            val dayStartRaw = item.optDouble(KEY_DAY_START_RAW, -1.0)
            val lastRaw = item.optDouble(KEY_LAST_RAW, -1.0)
            if (stepCount < 0 || capturedAtMillis <= 0L || dayStartRaw < 0.0 || lastRaw < 0.0) {
                continue
            }
            result[key] = StepCounterState(
                dayKey = key,
                capturedAtMillis = capturedAtMillis,
                stepCount = stepCount,
                dayStartRaw = dayStartRaw,
                lastRaw = lastRaw,
            )
        }
        return result
    }

    private fun writeHistory(history: Map<String, StepCounterState>) {
        val trimmed = history.entries
            .sortedByDescending { it.key }
            .take(MAX_HISTORY_DAYS)
        val root = JSONObject()
        for ((dayKey, state) in trimmed) {
            root.put(
                dayKey,
                JSONObject().apply {
                    put(KEY_STEP_COUNT, state.stepCount)
                    put(KEY_CAPTURED_AT, state.capturedAtMillis)
                    put(KEY_DAY_START_RAW, state.dayStartRaw)
                    put(KEY_LAST_RAW, state.lastRaw)
                },
            )
        }
        sharedPreferences.edit()
            .putString(KEY_DAILY_HISTORY, root.toString())
            .apply()
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    private data class StepCounterState(
        val dayKey: String,
        val capturedAtMillis: Long,
        val stepCount: Int,
        val dayStartRaw: Double,
        val lastRaw: Double,
    )

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
        private const val PREFS_NAME = "health_monitor_step_counter"
        private const val KEY_DAY_KEY = "dayKey"
        private const val KEY_STEP_COUNT = "stepCount"
        private const val KEY_DAY_START_RAW = "dayStartRaw"
        private const val KEY_LAST_RAW = "lastRaw"
        private const val KEY_CAPTURED_AT = "capturedAt"
        private const val KEY_DAILY_HISTORY = "dailyHistory"
        private const val MAX_HISTORY_DAYS = 30
    }
}

data class StepCounterDayPayload(
    val dayKey: String,
    val capturedAtMillis: Long,
    val stepCount: Int,
)

internal data class StepCounterHistorySnapshot(
    val dayKey: String,
    val capturedAtMillis: Long,
    val stepCount: Int,
    val dayStartRaw: Double,
    val lastRaw: Double,
)

internal fun recoverMissedPreviousDaySnapshot(
    currentDayKey: String,
    currentDayStartRaw: Double,
    history: Collection<StepCounterHistorySnapshot>,
    zoneId: ZoneId = ZoneId.systemDefault(),
): StepCounterHistorySnapshot? {
    val currentDate = runCatching { LocalDate.parse(currentDayKey) }.getOrNull()
        ?: return null
    val targetDate = currentDate.minusDays(1)
    val latestBeforeCurrent = history
        .mapNotNull { snapshot ->
            val date = runCatching { LocalDate.parse(snapshot.dayKey) }.getOrNull()
                ?: return@mapNotNull null
            if (date.isBefore(currentDate)) {
                date to snapshot
            } else {
                null
            }
        }
        .maxByOrNull { it.first }
        ?: return null
    val existingTarget = history.firstOrNull { it.dayKey == targetDate.toString() }
    if (existingTarget != null && existingTarget.stepCount > 0) {
        return null
    }

    val previousDate = latestBeforeCurrent.first
    val previousSnapshot = latestBeforeCurrent.second
    val gapStepCount = (currentDayStartRaw - previousSnapshot.lastRaw).toInt()
    if (gapStepCount <= 0) {
        return null
    }
    val recoveredStepCount = if (previousDate == targetDate) {
        previousSnapshot.stepCount + gapStepCount
    } else {
        gapStepCount
    }
    val capturedAtMillis = targetDate
        .plusDays(1)
        .atStartOfDay(zoneId)
        .toInstant()
        .toEpochMilli() - 1L
    return StepCounterHistorySnapshot(
        dayKey = targetDate.toString(),
        capturedAtMillis = capturedAtMillis,
        stepCount = recoveredStepCount,
        dayStartRaw = previousSnapshot.lastRaw,
        lastRaw = currentDayStartRaw,
    )
}
