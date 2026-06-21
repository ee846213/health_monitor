package com.example.health_monitor.background

data class AndroidWalkingScreenRiskEvent(
    val eventId: String,
    val occurredAtMillis: Long,
    val screenOnStartedAtMillis: Long,
    val continuousWalkingSeconds: Int,
    val stepDelta: Int,
    val notificationDelivered: Boolean = false,
) {
    fun toChannelMap(): Map<String, Any> {
        return mapOf(
            "eventId" to eventId,
            "occurredAtMillis" to occurredAtMillis,
            "screenOnStartedAtMillis" to screenOnStartedAtMillis,
            "continuousWalkingSeconds" to continuousWalkingSeconds,
            "stepDelta" to stepDelta,
            "notificationDelivered" to notificationDelivered,
        )
    }
}
