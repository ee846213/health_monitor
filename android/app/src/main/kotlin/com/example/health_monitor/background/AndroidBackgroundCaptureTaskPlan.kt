package com.example.health_monitor.background

data class AndroidBackgroundCaptureTaskPlan(
    val capabilityTags: List<String>,
    val cadenceMinutes: Int,
)

class AndroidBackgroundCaptureTaskPlanner {
    fun resolve(request: AndroidBackgroundCaptureRequest): AndroidBackgroundCaptureTaskPlan {
        // WorkManager 对周期任务有最小间隔要求，这里主动抬到 15 分钟，避免计划在设备上无法落地。
        val cadenceMinutes = request.sampleIntervalMinutes.coerceAtLeast(15)
        val capabilityTags = buildList {
            if (request.enableMotion) {
                add(CAPABILITY_MOTION)
            }
            if (request.enableLocation) {
                add(CAPABILITY_LOCATION)
            }
            if (request.enableNoise) {
                add(CAPABILITY_NOISE)
            }
            if (request.enableDigitalUsage) {
                add(CAPABILITY_DIGITAL_USAGE)
            }
        }
        return AndroidBackgroundCaptureTaskPlan(
            capabilityTags = capabilityTags,
            cadenceMinutes = cadenceMinutes,
        )
    }

    companion object {
        const val CAPABILITY_MOTION = "motion"
        const val CAPABILITY_LOCATION = "location"
        const val CAPABILITY_NOISE = "noise"
        const val CAPABILITY_DIGITAL_USAGE = "digital_usage"
        const val CAPABILITY_RECOVERY = "recovery"
    }
}
