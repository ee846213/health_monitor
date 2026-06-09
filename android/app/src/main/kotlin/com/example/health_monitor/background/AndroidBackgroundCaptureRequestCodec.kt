package com.example.health_monitor.background

import org.json.JSONObject

object AndroidBackgroundCaptureRequestCodec {
    fun encode(request: AndroidBackgroundCaptureRequest): String {
        return JSONObject()
            .put("notificationTitle", request.notificationTitle)
            .put("notificationBody", request.notificationBody)
            .put("enableMotion", request.enableMotion)
            .put("enableLocation", request.enableLocation)
            .put("enableNoise", request.enableNoise)
            .put("enableDigitalUsage", request.enableDigitalUsage)
            .put("sampleIntervalMinutes", request.sampleIntervalMinutes)
            .toString()
    }

    fun decode(serialized: String): AndroidBackgroundCaptureRequest {
        val json = JSONObject(serialized)
        return AndroidBackgroundCaptureRequest(
            notificationTitle = json.getString("notificationTitle"),
            notificationBody = json.getString("notificationBody"),
            enableMotion = json.getBoolean("enableMotion"),
            enableLocation = json.getBoolean("enableLocation"),
            enableNoise = json.getBoolean("enableNoise"),
            enableDigitalUsage = json.getBoolean("enableDigitalUsage"),
            sampleIntervalMinutes = json.getInt("sampleIntervalMinutes"),
        )
    }
}
