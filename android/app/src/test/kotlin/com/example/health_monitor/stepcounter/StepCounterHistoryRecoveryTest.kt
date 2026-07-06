package com.example.health_monitor.stepcounter

import java.time.ZoneId
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class StepCounterHistoryRecoveryTest {
    @Test
    fun shouldRecoverMissingPreviousDayFromRawGap() {
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

        requireNotNull(recovered)
        assertEquals("2026-07-06", recovered.dayKey)
        assertEquals(7899, recovered.stepCount)
        assertEquals(27041.0, recovered.lastRaw, 0.0)
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
}
