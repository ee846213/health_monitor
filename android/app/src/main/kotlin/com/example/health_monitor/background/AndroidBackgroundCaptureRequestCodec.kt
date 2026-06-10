package com.example.health_monitor.background

import java.net.URLDecoder
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

object AndroidBackgroundCaptureRequestCodec {
    private const val ENTRY_SEPARATOR = "&"
    private const val KEY_VALUE_SEPARATOR = "="

    fun encode(request: AndroidBackgroundCaptureRequest): String {
        // 这里使用纯 JDK 的 querystring 形式做序列化，避免宿主单测依赖 Android stub 版 JSONObject。
        // 后台请求只在宿主进程与测试代码之间流转，不需要引入更重的 JSON 依赖。
        return linkedMapOf(
            "notificationTitle" to request.notificationTitle,
            "notificationBody" to request.notificationBody,
            "enableMotion" to request.enableMotion.toString(),
            "enableLocation" to request.enableLocation.toString(),
            "enableNoise" to request.enableNoise.toString(),
            "enableDigitalUsage" to request.enableDigitalUsage.toString(),
            "sampleIntervalMinutes" to request.sampleIntervalMinutes.toString(),
        ).entries.joinToString(separator = ENTRY_SEPARATOR) { (key, value) ->
            "${encodeValue(key)}$KEY_VALUE_SEPARATOR${encodeValue(value)}"
        }
    }

    fun decode(serialized: String): AndroidBackgroundCaptureRequest {
        val values = serialized
            .split(ENTRY_SEPARATOR)
            .filter(String::isNotBlank)
            .associate { entry ->
                val separatorIndex = entry.indexOf(KEY_VALUE_SEPARATOR)
                require(separatorIndex >= 0) {
                    "Android 后台采集请求编码缺少键值分隔符: $entry"
                }
                val key = decodeValue(entry.substring(0, separatorIndex))
                val value = decodeValue(entry.substring(separatorIndex + 1))
                key to value
            }

        return AndroidBackgroundCaptureRequest(
            notificationTitle = values.requireValue("notificationTitle"),
            notificationBody = values.requireValue("notificationBody"),
            enableMotion = values.requireValue("enableMotion").toBooleanStrict(),
            enableLocation = values.requireValue("enableLocation").toBooleanStrict(),
            enableNoise = values.requireValue("enableNoise").toBooleanStrict(),
            enableDigitalUsage = values.requireValue("enableDigitalUsage").toBooleanStrict(),
            sampleIntervalMinutes = values.requireValue("sampleIntervalMinutes").toInt(),
        )
    }

    private fun encodeValue(value: String): String {
        return URLEncoder.encode(value, StandardCharsets.UTF_8)
    }

    private fun decodeValue(value: String): String {
        return URLDecoder.decode(value, StandardCharsets.UTF_8)
    }

    private fun Map<String, String>.requireValue(key: String): String {
        return get(key) ?: error("Android 后台采集请求编码缺少字段: $key")
    }
}
