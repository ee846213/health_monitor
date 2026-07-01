package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidBackgroundStepDeltaStoreTest {
    @Test
    fun drainShouldReturnQueuedEventsAndClearStore() {
        val store = InMemoryAndroidBackgroundStepDeltaStore()
        val event = AndroidBackgroundStepDeltaEvent(
            eventId = "2026-06-22-1000-30",
            capturedAtMillis = 1_000L,
            stepDelta = 30,
            dayStepTotal = 130,
        )

        store.append(event)
        val drained = store.drain()

        assertEquals(listOf(event), drained)
        assertEquals(emptyList<AndroidBackgroundStepDeltaEvent>(), store.drain())
    }

    @Test
    fun drainShouldPreserveStationaryDuration() {
        val store = InMemoryAndroidBackgroundStepDeltaStore()
        val event = AndroidBackgroundStepDeltaEvent(
            eventId = "2026-06-22-1000-stationary",
            capturedAtMillis = 1_000L,
            stepDelta = 0,
            dayStepTotal = 130,
            stationaryDurationMillis = 900_000L,
        )

        store.append(event)
        val drained = store.drain()

        assertEquals(listOf(event), drained)
    }
}
