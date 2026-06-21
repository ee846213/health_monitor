package com.example.health_monitor.background

class AndroidWalkingScreenRiskDetector(
    private val thresholdSeconds: Int = 8,
    private val minimumStepDelta: Int = 4,
    private val movementGapToleranceSeconds: Int = 2,
) {
    private var screenOnStartedAtMillis: Long? = null
    private var lastStepCount: Int? = null
    private var accumulatedStepDelta: Int = 0
    private var movementStartedAtMillis: Long? = null
    private var lastMovementAtMillis: Long? = null
    private var triggeredForCurrentSession: Boolean = false

    fun onScreenTurnedOn(nowMillis: Long) {
        screenOnStartedAtMillis = nowMillis
        lastStepCount = null
        accumulatedStepDelta = 0
        movementStartedAtMillis = null
        lastMovementAtMillis = null
        triggeredForCurrentSession = false
    }

    fun onScreenTurnedOff() {
        screenOnStartedAtMillis = null
        lastStepCount = null
        accumulatedStepDelta = 0
        movementStartedAtMillis = null
        lastMovementAtMillis = null
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

        if (stepDelta > 0) {
            val previousMovementAt = lastMovementAtMillis
            if (
                previousMovementAt == null ||
                nowMillis - previousMovementAt >= movementGapToleranceSeconds * 1_000L
            ) {
                accumulatedStepDelta = 0
                // TYPE_STEP_COUNTER 可能逐步上报，也可能一次批量跳增。
                // 用本次步数增量回填一个保守的运动起点，既保持逐秒上报第 8 秒触发，
                // 也允许批量上报在证据到达时恢复此前已经发生的步行时长。
                movementStartedAtMillis = (
                    nowMillis - stepDelta.coerceAtMost(thresholdSeconds) * 1_000L
                ).coerceAtLeast(screenOnStartedAtMillis)
            }
            accumulatedStepDelta += stepDelta
            lastMovementAtMillis = nowMillis
        } else if (
            lastMovementAtMillis != null &&
            nowMillis - lastMovementAtMillis!! >= movementGapToleranceSeconds * 1_000L
        ) {
            accumulatedStepDelta = 0
            movementStartedAtMillis = null
            lastMovementAtMillis = null
        }

        val screenOnSeconds = ((nowMillis - screenOnStartedAtMillis) / 1_000L).toInt()
        val hasRecentMovement = lastMovementAtMillis?.let {
            nowMillis - it <= movementGapToleranceSeconds * 1_000L
        } == true
        val walkingSeconds = movementStartedAtMillis
            ?.let { ((nowMillis - it) / 1_000L).toInt() }
            ?: 0
        if (
            triggeredForCurrentSession ||
            screenOnSeconds < thresholdSeconds ||
            walkingSeconds < thresholdSeconds ||
            !hasRecentMovement ||
            accumulatedStepDelta < minimumStepDelta
        ) {
            return null
        }

        triggeredForCurrentSession = true
        return AndroidWalkingScreenRiskEvent(
            eventId = "$screenOnStartedAtMillis-$nowMillis-$accumulatedStepDelta",
            occurredAtMillis = nowMillis,
            screenOnStartedAtMillis = screenOnStartedAtMillis,
            continuousWalkingSeconds = walkingSeconds,
            stepDelta = accumulatedStepDelta,
        )
    }
}
