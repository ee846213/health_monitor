package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidBackgroundCaptureRequestCodecTest {
    @Test
    fun encodeAndDecodeShouldRoundTripRequest() {
        val request = AndroidBackgroundCaptureRequest(
            notificationTitle = "健康监测正在后台运行",
            notificationBody = "用于持续积累活动、位置与用机样本。",
            enableMotion = true,
            enableLocation = true,
            enableNoise = false,
            enableDigitalUsage = true,
            sampleIntervalMinutes = 15,
        )

        val serialized = AndroidBackgroundCaptureRequestCodec.encode(request)
        val decoded = AndroidBackgroundCaptureRequestCodec.decode(serialized)

        assertEquals(request, decoded)
    }
}
