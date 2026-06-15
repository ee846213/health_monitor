package com.example.health_monitor.light

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

class AndroidAmbientLightStreamHandler(
    context: Context,
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private val lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        val manager = sensorManager
        if (manager == null) {
            events.error(
                "sensor_manager_unavailable",
                "Android 设备未提供 SensorManager，无法读取光照传感器。",
                null,
            )
            return
        }
        val sensor = lightSensor
        if (sensor == null) {
            events.error(
                "light_sensor_unavailable",
                "当前设备不支持环境光照传感器。",
                null,
            )
            return
        }
        if (!manager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)) {
            events.error(
                "light_sensor_register_failed",
                "环境光照监听注册失败。",
                null,
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager?.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_LIGHT) {
            return
        }
        val lux = event.values.firstOrNull()?.toDouble() ?: return
        eventSink?.success(
            mapOf(
                "capturedAtMillis" to System.currentTimeMillis(),
                "lux" to lux,
            ),
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
}
