package com.example.health_monitor.usagestats

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

interface AndroidUsageSummarySnapshotStore {
    fun enqueue(snapshot: AndroidUsageSummarySnapshot)

    fun drain(): List<AndroidUsageSummarySnapshot>
}

class SharedPreferencesAndroidUsageSummarySnapshotStore(
    private val sharedPreferences: SharedPreferences,
) : AndroidUsageSummarySnapshotStore {
    override fun enqueue(snapshot: AndroidUsageSummarySnapshot) {
        val array = JSONArray(sharedPreferences.getString(KEY_QUEUE, "[]") ?: "[]")
        val payload = JSONObject()
            .put("dateKey", snapshot.dateKey)
            .put("screenOnDurationMillis", snapshot.screenOnDurationMillis)
            .put("unlockCount", snapshot.unlockCount)
            .put("viewCount", snapshot.viewCount)
            .put("nighttimeUsageDurationMillis", snapshot.nighttimeUsageDurationMillis)
            .put("focusSessionBreakCount", snapshot.focusSessionBreakCount)
            .put("longestContinuousUsageDurationMillis", snapshot.longestContinuousUsageDurationMillis)
            .put("topCategoryKey", snapshot.topCategoryKey)
            .put("completenessKey", snapshot.completenessKey)
        array.put(payload)
        sharedPreferences.edit().putString(KEY_QUEUE, array.toString()).apply()
    }

    override fun drain(): List<AndroidUsageSummarySnapshot> {
        val raw = sharedPreferences.getString(KEY_QUEUE, "[]") ?: "[]"
        val array = JSONArray(raw)
        val snapshots = mutableListOf<AndroidUsageSummarySnapshot>()
        for (index in 0 until array.length()) {
            val item = array.optJSONObject(index) ?: continue
            snapshots.add(
                AndroidUsageSummarySnapshot(
                    dateKey = item.optString("dateKey"),
                    screenOnDurationMillis = item.optLong("screenOnDurationMillis"),
                    unlockCount = item.optInt("unlockCount"),
                    viewCount = item.optInt("viewCount"),
                    nighttimeUsageDurationMillis = item.optLong("nighttimeUsageDurationMillis"),
                    focusSessionBreakCount = item.optInt("focusSessionBreakCount"),
                    longestContinuousUsageDurationMillis = item.optLong("longestContinuousUsageDurationMillis"),
                    topCategoryKey = item.optString("topCategoryKey", "unknown"),
                    completenessKey = item.optString("completenessKey", "full"),
                ),
            )
        }
        sharedPreferences.edit().remove(KEY_QUEUE).apply()
        return snapshots
    }

    companion object {
        private const val KEY_QUEUE = "android_usage_summary_snapshot_queue"
    }
}
