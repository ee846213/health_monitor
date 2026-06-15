package com.example.health_monitor.background

class AndroidWalkingScreenRiskDetector(
    private val thresholdSeconds: Int = 8,
) {
    private var screenOnStartedAtMillis: Long? = null
    private var lastStepCount: Int? = null
    private var continuousWalkingSeconds: Int = 0
    private var accumulatedStepDelta: Int = 0
    private var triggeredForCurrentSession: Boolean = false

    fun onScreenTurnedOn(nowMillis: Long) {
        screenOnStartedAtMillis = nowMillis
        lastStepCount = null
        continuousWalkingSeconds = 0
        accumulatedStepDelta = 0
        triggeredForCurrentSession = false
    }

    fun onScreenTurnedOff() {
        screenOnStartedAtMillis = null
        lastStepCount = null
        continuousWalkingSeconds = 0
        accumulatedStepDelta = 0
        triggeredForCurrentSession = false
    }

    fun poll(
        nowMillis: Long,
        currentStepCount: Int,
    ): AndroidWalkingScreenRiskEvent? {
        val screenOnStartedAtMillis = screenOnStartedAtMillis ?: return null
        val lastStepCount = lastStepCount
        if (lastStepCount == null) {
            this.lastStepCount = currentStepCount
            return null
        }

        val stepDelta = currentStepCount - lastStepCount
        this.lastStepCount = currentStepCount

        if (stepDelta >= 1) {
            continuousWalkingSeconds += 1
            accumulatedStepDelta += stepDelta
        } else {
            continuousWalkingSeconds = 0
            accumulatedStepDelta = 0
        }

        if (triggeredForCurrentSession || continuousWalkingSeconds < thresholdSeconds) {
            return null
        }

        triggeredForCurrentSession = true
        return AndroidWalkingScreenRiskEvent(
            eventId = "$screenOnStartedAtMillis-$nowMillis-$accumulatedStepDelta",
            occurredAtMillis = nowMillis,
            screenOnStartedAtMillis = screenOnStartedAtMillis,
            continuousWalkingSeconds = continuousWalkingSeconds,
            stepDelta = accumulatedStepDelta,
        )
    }
}
