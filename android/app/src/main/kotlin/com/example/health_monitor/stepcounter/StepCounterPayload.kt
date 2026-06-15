package com.example.health_monitor.stepcounter

data class StepCounterPayload(
    val capturedAtMillis: Long,
    val stepCount: Int,
    val isAvailable: Boolean,
    val reason: String? = null,
)
