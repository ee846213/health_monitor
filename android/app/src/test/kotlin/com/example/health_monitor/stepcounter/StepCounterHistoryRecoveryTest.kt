package com.example.health_monitor.stepcounter

import java.time.ZoneId
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class StepCounterHistoryRecoveryTest {
    @Test
    fun shouldNotRecoverMissingPreviousDayFromRawGap() {
        val recovered = recoverMissedPreviousDaySnapshot(
            currentDayKey = "2026-07-07",
            currentDayStartRaw = 27041.0,
            history = listOf(
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-05",
                    capturedAtMillis = 1783253207214,
                    stepCount = 86,
                    dayStartRaw = 19056.0,
                    lastRaw = 19142.0,
                ),
            ),
            zoneId = ZoneId.of("Asia/Shanghai"),
        )

        assertNull(recovered)
    }

    @Test
    fun shouldKeepExistingPreviousDaySnapshot() {
        val recovered = recoverMissedPreviousDaySnapshot(
            currentDayKey = "2026-07-07",
            currentDayStartRaw = 27041.0,
            history = listOf(
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-06",
                    capturedAtMillis = 1783353599999,
                    stepCount = 6200,
                    dayStartRaw = 19142.0,
                    lastRaw = 25342.0,
                ),
            ),
            zoneId = ZoneId.of("Asia/Shanghai"),
        )

        assertNull(recovered)
    }

    @Test
    fun shouldDropAmbiguousRecoveredSnapshotFromOldHistory() {
        val sanitized = sanitizeAmbiguousStepCounterHistory(
            listOf(
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-09",
                    capturedAtMillis = 1783612800000,
                    stepCount = 0,
                    dayStartRaw = 15.0,
                    lastRaw = 15.0,
                ),
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-12",
                    capturedAtMillis = 1783871999999,
                    stepCount = 11941,
                    dayStartRaw = 15.0,
                    lastRaw = 11956.0,
                ),
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-13",
                    capturedAtMillis = 1783900800000,
                    stepCount = 0,
                    dayStartRaw = 11956.0,
                    lastRaw = 11956.0,
                ),
            ),
        )

        assertEquals(listOf("2026-07-09", "2026-07-13"), sanitized.map { it.dayKey })
    }

    @Test
    fun shouldDropSingleDayRawGapRecoveredSnapshotFromOldHistory() {
        val sanitized = sanitizeAmbiguousStepCounterHistory(
            listOf(
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-05",
                    capturedAtMillis = 1783253207214,
                    stepCount = 86,
                    dayStartRaw = 19056.0,
                    lastRaw = 19142.0,
                ),
                StepCounterHistorySnapshot(
                    dayKey = "2026-07-06",
                    capturedAtMillis = 1783353599999,
                    stepCount = 7899,
                    dayStartRaw = 19142.0,
                    lastRaw = 27041.0,
                ),
            ),
        )

        assertEquals(listOf("2026-07-05"), sanitized.map { it.dayKey })
    }
}
