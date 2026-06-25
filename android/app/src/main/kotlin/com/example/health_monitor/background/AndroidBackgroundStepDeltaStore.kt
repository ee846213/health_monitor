package com.example.health_monitor.background

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

interface AndroidBackgroundStepDeltaStore {
    fun append(event: AndroidBackgroundStepDeltaEvent)

    fun drain(): List<AndroidBackgroundStepDeltaEvent>
}

class InMemoryAndroidBackgroundStepDeltaStore : AndroidBackgroundStepDeltaStore {
    private val events = mutableListOf<AndroidBackgroundStepDeltaEvent>()

    override fun append(event: AndroidBackgroundStepDeltaEvent) {
        events.add(event)
    }

    override fun drain(): List<AndroidBackgroundStepDeltaEvent> {
        val drained = events.toList()
        events.clear()
        return drained
    }
}

class SharedPreferencesAndroidBackgroundStepDeltaStore(
    private val sharedPreferences: SharedPreferences,
) : AndroidBackgroundStepDeltaStore {
    override fun append(event: AndroidBackgroundStepDeltaEvent) {
        val current = readArray()
        val next = JSONArray()
        val overflow = current.length() - MAX_QUEUE_SIZE + 1
        val startIndex = if (overflow > 0) overflow else 0
        for (index in startIndex until current.length()) {
            next.put(current.get(index))
        }
        next.put(event.toJson())
        sharedPreferences.edit()
            .putString(KEY_QUEUE, next.toString())
            .apply()
    }

    override fun drain(): List<AndroidBackgroundStepDeltaEvent> {
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
        private const val KEY_QUEUE = "android_background_step_delta_queue"
        private const val MAX_QUEUE_SIZE = 96
    }
}

private fun AndroidBackgroundStepDeltaEvent.toJson(): JSONObject {
    return JSONObject().apply {
        put("eventId", eventId)
        put("capturedAtMillis", capturedAtMillis)
        put("stepDelta", stepDelta)
        put("dayStepTotal", dayStepTotal)
    }
}

private fun JSONObject.toEvent(): AndroidBackgroundStepDeltaEvent {
    return AndroidBackgroundStepDeltaEvent(
        eventId = optString("eventId"),
        capturedAtMillis = optLong("capturedAtMillis"),
        stepDelta = optInt("stepDelta"),
        dayStepTotal = optInt("dayStepTotal"),
    )
}
