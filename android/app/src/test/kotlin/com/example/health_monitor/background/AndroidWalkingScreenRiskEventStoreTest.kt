package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Test

class AndroidWalkingScreenRiskEventStoreTest {
    @Test
    fun drainShouldReturnEventsAndClearQueue() {
        val store = InMemoryAndroidWalkingScreenRiskEventStore()
        store.append(
            AndroidWalkingScreenRiskEvent(
                eventId = "risk-1",
                occurredAtMillis = 1_000L,
                screenOnStartedAtMillis = 0L,
                continuousWalkingSeconds = 8,
                stepDelta = 10,
            ),
        )

        val firstDrain = store.drain()
        val secondDrain = store.drain()

        assertEquals(1, firstDrain.size)
        assertEquals("risk-1", firstDrain.single().eventId)
        assertEquals(0, secondDrain.size)
    }
}
