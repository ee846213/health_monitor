package com.example.health_monitor.background

data class AndroidBackgroundStepDeltaEvent(
    val eventId: String,
    val capturedAtMillis: Long,
    val stepDelta: Int,
    val dayStepTotal: Int,
    val stationaryDurationMillis: Long = 0L,
)

fun AndroidBackgroundStepDeltaEvent.toChannelMap(): Map<String, Any?> {
    return mapOf(
        "eventId" to eventId,
        "capturedAtMillis" to capturedAtMillis,
        "stepDelta" to stepDelta,
        "dayStepTotal" to dayStepTotal,
        "stationaryDurationMillis" to stationaryDurationMillis,
    )
}
