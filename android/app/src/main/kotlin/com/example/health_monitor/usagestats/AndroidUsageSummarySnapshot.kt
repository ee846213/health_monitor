package com.example.health_monitor.usagestats

data class AndroidUsageSummarySnapshot(
    val dateKey: String,
    val screenOnDurationMillis: Long,
    val unlockCount: Int,
    val viewCount: Int,
    val nighttimeUsageDurationMillis: Long,
    val focusSessionBreakCount: Int,
    val longestContinuousUsageDurationMillis: Long,
    val topCategoryKey: String,
    val completenessKey: String = "full",
) {
    fun toChannelMap(): Map<String, Any> {
        return mapOf(
            "dateKey" to dateKey,
            "screenOnDurationMillis" to screenOnDurationMillis,
            "unlockCount" to unlockCount,
            "viewCount" to viewCount,
            "nighttimeUsageDurationMillis" to nighttimeUsageDurationMillis,
            "focusSessionBreakCount" to focusSessionBreakCount,
            "longestContinuousUsageDurationMillis" to longestContinuousUsageDurationMillis,
            "topCategoryKey" to topCategoryKey,
            "completenessKey" to completenessKey,
        )
    }
}
