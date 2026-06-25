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
import java.util.Calendar
import java.util.concurrent.atomic.AtomicBoolean

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
                StepCounterState(
                    dayKey = nowDayKey,
                    capturedAtMillis = now,
                    stepCount = 0,
                    dayStartRaw = rawTotal,
                    lastRaw = rawTotal,
                )
            }

            rawTotal < currentState.lastRaw -> {
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

        sharedPreferences.edit()
            .putString(KEY_DAY_KEY, nextState.dayKey)
            .putInt(KEY_STEP_COUNT, nextState.stepCount)
            .putFloat(KEY_DAY_START_RAW, nextState.dayStartRaw.toFloat())
            .putFloat(KEY_LAST_RAW, nextState.lastRaw.toFloat())
            .putLong(KEY_CAPTURED_AT, nextState.capturedAtMillis)
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
    }
}
