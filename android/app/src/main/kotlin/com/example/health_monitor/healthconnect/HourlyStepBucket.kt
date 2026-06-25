package com.example.health_monitor.healthconnect

data class HourlyStepBucket(
    val startMillis: Long,
    val endMillis: Long,
    val stepCount: Int,
)

fun HourlyStepBucket.toChannelMap(): Map<String, Any?> {
    return mapOf(
        "startMillis" to startMillis,
        "endMillis" to endMillis,
        "stepCount" to stepCount,
    )
}
