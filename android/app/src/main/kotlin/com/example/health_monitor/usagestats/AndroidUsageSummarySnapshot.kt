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
    // 最长连续使用片段的起点（毫秒时间戳）。仅在能定位到具体会话时填充，
    // 供节奏轴把数字习惯节点放到真实发生的时间上；无法定位时为 null。
    val longestContinuousUsageStartedAtMillis: Long? = null,
) {
    fun toChannelMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>(
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
        longestContinuousUsageStartedAtMillis?.let {
            map["longestContinuousUsageStartedAtMillis"] = it
        }
        return map
    }
}
