package com.example.health_monitor.background

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

interface AndroidWalkingScreenRiskEventStore {
    fun append(event: AndroidWalkingScreenRiskEvent)

    fun drain(): List<AndroidWalkingScreenRiskEvent>
}

class InMemoryAndroidWalkingScreenRiskEventStore : AndroidWalkingScreenRiskEventStore {
    private val events = mutableListOf<AndroidWalkingScreenRiskEvent>()

    override fun append(event: AndroidWalkingScreenRiskEvent) {
        events.add(event)
    }

    override fun drain(): List<AndroidWalkingScreenRiskEvent> {
        val drained = events.toList()
        events.clear()
        return drained
    }
}

class SharedPreferencesAndroidWalkingScreenRiskEventStore(
    private val sharedPreferences: SharedPreferences,
) : AndroidWalkingScreenRiskEventStore {
    override fun append(event: AndroidWalkingScreenRiskEvent) {
        val current = readArray()
        current.put(event.toJson())
        sharedPreferences.edit()
            .putString(KEY_QUEUE, current.toString())
            .apply()
    }

    override fun drain(): List<AndroidWalkingScreenRiskEvent> {
        val current = readArray()
        val events = buildList {
            for (index in 0 until current.length()) {
                val item = current.optJSONObject(index) ?: continue
                add(item.toEvent())
            }
        }
        sharedPreferences.edit()
            .remove(KEY_QUEUE)
            .apply()
        return events
    }

    private fun readArray(): JSONArray {
        val raw = sharedPreferences.getString(KEY_QUEUE, null) ?: return JSONArray()
        return runCatching { JSONArray(raw) }.getOrElse { JSONArray() }
    }

    companion object {
        private const val KEY_QUEUE = "android_walking_screen_risk_event_queue"
    }
}

private fun AndroidWalkingScreenRiskEvent.toJson(): JSONObject {
    return JSONObject().apply {
        put("eventId", eventId)
        put("occurredAtMillis", occurredAtMillis)
        put("screenOnStartedAtMillis", screenOnStartedAtMillis)
        put("continuousWalkingSeconds", continuousWalkingSeconds)
        put("stepDelta", stepDelta)
        put("notificationDelivered", notificationDelivered)
    }
}

private fun JSONObject.toEvent(): AndroidWalkingScreenRiskEvent {
    return AndroidWalkingScreenRiskEvent(
        eventId = optString("eventId"),
        occurredAtMillis = optLong("occurredAtMillis"),
        screenOnStartedAtMillis = optLong("screenOnStartedAtMillis"),
        continuousWalkingSeconds = optInt("continuousWalkingSeconds"),
        stepDelta = optInt("stepDelta"),
        notificationDelivered = optBoolean("notificationDelivered", false),
    )
}
