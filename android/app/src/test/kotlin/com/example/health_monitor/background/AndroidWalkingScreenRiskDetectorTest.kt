package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test

class AndroidWalkingScreenRiskDetectorTest {
    @Test
    fun shouldNotTriggerWhenScreenOnButStepCountDoesNotIncrease() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)

        repeat(9) { second ->
            val event = detector.poll(
                nowMillis = 2_000L + second * 1_000L,
                currentStepCount = 10,
            )
            assertNull(event)
        }
    }

    @Test
    fun shouldTriggerOnceAfterEightContinuousWalkingSeconds() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)
        detector.poll(nowMillis = 2_000L, currentStepCount = 10)

        var event: AndroidWalkingScreenRiskEvent? = null
        repeat(8) { second ->
            event = detector.poll(
                nowMillis = 3_000L + second * 1_000L,
                currentStepCount = 11 + second,
            )
        }

        assertNotNull(event)
        assertEquals(8, event?.continuousWalkingSeconds)
        assertNull(
            detector.poll(
                nowMillis = 20_000L,
                currentStepCount = 30,
            ),
        )
    }

    @Test
    fun shouldAcceptBatchedStepCounterDelivery() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)
        detector.poll(nowMillis = 2_000L, currentStepCount = 100)

        repeat(6) { second ->
            assertNull(
                detector.poll(
                    nowMillis = 3_000L + second * 1_000L,
                    currentStepCount = 100,
                ),
            )
        }

        val event = detector.poll(
            nowMillis = 9_000L,
            currentStepCount = 108,
        )

        assertNotNull(event)
        assertEquals(8, event?.stepDelta)
    }

    @Test
    fun staleMovementShouldNotTriggerAfterWalkingStops() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)
        detector.poll(nowMillis = 2_000L, currentStepCount = 10)
        detector.poll(nowMillis = 3_000L, currentStepCount = 14)

        assertNull(detector.poll(nowMillis = 7_000L, currentStepCount = 14))
        assertNull(detector.poll(nowMillis = 10_000L, currentStepCount = 14))
    }

    @Test
    fun shouldResetWhenWalkingStopsBeforeThreshold() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)
        detector.poll(nowMillis = 2_000L, currentStepCount = 10)

        repeat(5) { second ->
            assertNull(
                detector.poll(
                    nowMillis = 3_000L + second * 1_000L,
                    currentStepCount = 11 + second,
                ),
            )
        }
        assertNull(detector.poll(nowMillis = 9_000L, currentStepCount = 15))

        repeat(8) { second ->
            val stepCount = 16 + second
            val event = detector.poll(
                nowMillis = 10_000L + second * 1_000L,
                currentStepCount = stepCount,
            )
            if (second < 7) {
                assertNull(event)
            } else {
                assertNotNull(event)
            }
        }
    }

    @Test
    fun shouldAllowNewSessionAfterScreenTurnsOff() {
        val detector = AndroidWalkingScreenRiskDetector()
        detector.onScreenTurnedOn(1_000L)
        detector.poll(nowMillis = 2_000L, currentStepCount = 10)
        repeat(8) { second ->
            detector.poll(
                nowMillis = 3_000L + second * 1_000L,
                currentStepCount = 11 + second,
            )
        }

        detector.onScreenTurnedOff()
        detector.onScreenTurnedOn(20_000L)
        detector.poll(nowMillis = 21_000L, currentStepCount = 30)

        var secondSessionEvent: AndroidWalkingScreenRiskEvent? = null
        repeat(8) { second ->
            secondSessionEvent = detector.poll(
                nowMillis = 22_000L + second * 1_000L,
                currentStepCount = 31 + second,
            )
        }

        assertNotNull(secondSessionEvent)
    }
}
