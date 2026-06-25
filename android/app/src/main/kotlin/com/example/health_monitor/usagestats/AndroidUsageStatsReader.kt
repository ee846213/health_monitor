package com.example.health_monitor.usagestats

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import java.time.Instant
import java.time.ZoneId
import kotlin.math.max

data class AndroidUsageCapabilityStatus(
    val isSupported: Boolean,
    val hasUsageAccess: Boolean,
) {
    fun toChannelMap(): Map<String, Any> {
        return mapOf(
            "isSupported" to isSupported,
            "hasUsageAccess" to hasUsageAccess,
        )
    }
}

class AndroidUsageStatsReader(
    private val context: Context,
) {
    fun getCapabilityStatus(): AndroidUsageCapabilityStatus {
        return AndroidUsageCapabilityStatus(
            isSupported = Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP,
            hasUsageAccess = hasUsageAccess(),
        )
    }

    fun readDailySummary(referenceTimeMillis: Long = System.currentTimeMillis()): AndroidUsageSummarySnapshot? {
        if (!getCapabilityStatus().canReadUsageStats()) {
            return null
        }

        val zoneId = ZoneId.systemDefault()
        val referenceTime = Instant.ofEpochMilli(referenceTimeMillis).atZone(zoneId)
        val dayStart = referenceTime.toLocalDate().atStartOfDay(zoneId).toInstant().toEpochMilli()
        return buildSummary(
            dateKey = referenceTime.toLocalDate().toString(),
            startMillis = dayStart,
            endMillis = referenceTimeMillis,
        )
    }

    fun readRangeSummaries(startMillis: Long, endMillis: Long): List<AndroidUsageSummarySnapshot> {
        if (!getCapabilityStatus().canReadUsageStats()) {
            return emptyList()
        }
        if (endMillis <= startMillis) {
            return emptyList()
        }

        val zoneId = ZoneId.systemDefault()
        val startDate = Instant.ofEpochMilli(startMillis).atZone(zoneId).toLocalDate()
        val endDate = Instant.ofEpochMilli(max(startMillis, endMillis - 1)).atZone(zoneId).toLocalDate()
        val result = mutableListOf<AndroidUsageSummarySnapshot>()
        var cursor = startDate
        while (!cursor.isAfter(endDate)) {
            val dayStart = cursor.atStartOfDay(zoneId).toInstant().toEpochMilli()
            val dayEnd = cursor.plusDays(1).atStartOfDay(zoneId).toInstant().toEpochMilli()
            val clippedStart = max(startMillis, dayStart)
            val clippedEnd = minOf(endMillis, dayEnd)
            if (clippedEnd > clippedStart) {
                buildSummary(
                    dateKey = cursor.toString(),
                    startMillis = clippedStart,
                    endMillis = clippedEnd,
                )?.let(result::add)
            }
            cursor = cursor.plusDays(1)
        }
        return result
    }

    private fun buildSummary(
        dateKey: String,
        startMillis: Long,
        endMillis: Long,
    ): AndroidUsageSummarySnapshot? {
        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return null

        var interactiveStartedAt: Long? = null
        var sessionStartedAt: Long? = null
        var screenOnDurationMillis = 0L
        var unlockCount = 0
        var viewCount = 0
        var nighttimeUsageDurationMillis = 0L
        var focusSessionBreakCount = 0
        var longestContinuousUsageDurationMillis = 0L
        var longestContinuousUsageStartedAtMillis: Long? = null
        var lastSessionEndedAt: Long? = null
        val activePackages = mutableMapOf<String, Long>()
        val packageForegroundDurations = mutableMapOf<String, Long>()

        val events = usageStatsManager.queryEvents(startMillis, endMillis)
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val timestamp = event.timeStamp
            when (event.eventType) {
                UsageEvents.Event.SCREEN_INTERACTIVE -> {
                    if (interactiveStartedAt == null) {
                        interactiveStartedAt = timestamp
                    }
                }

                UsageEvents.Event.SCREEN_NON_INTERACTIVE -> {
                    interactiveStartedAt?.let { startedAt ->
                        screenOnDurationMillis += (timestamp - startedAt).coerceAtLeast(0L)
                    }
                    interactiveStartedAt = null
                    sessionStartedAt = closeSession(
                        sessionStartedAt = sessionStartedAt,
                        endedAt = timestamp,
                    ) { startedAt, endedAt ->
                        val duration = (endedAt - startedAt).coerceAtLeast(0L)
                        nighttimeUsageDurationMillis += nightOverlapMillis(startedAt, endedAt)
                        if (duration > longestContinuousUsageDurationMillis) {
                            longestContinuousUsageDurationMillis = duration
                            longestContinuousUsageStartedAtMillis = startedAt
                        }
                        lastSessionEndedAt = endedAt
                    }
                    closeForegroundPackages(
                        activePackages = activePackages,
                        packageForegroundDurations = packageForegroundDurations,
                        closedAt = timestamp,
                    )
                }

                UsageEvents.Event.KEYGUARD_HIDDEN -> {
                    unlockCount += 1
                    if (interactiveStartedAt != null && sessionStartedAt == null) {
                        viewCount += 1
                        if (lastSessionEndedAt != null &&
                            timestamp - lastSessionEndedAt!! <= SESSION_GAP_THRESHOLD_MILLIS
                        ) {
                            focusSessionBreakCount += 1
                        }
                        sessionStartedAt = timestamp
                    }
                }

                UsageEvents.Event.ACTIVITY_RESUMED,
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (interactiveStartedAt != null && sessionStartedAt == null) {
                        viewCount += 1
                        if (lastSessionEndedAt != null &&
                            timestamp - lastSessionEndedAt!! <= SESSION_GAP_THRESHOLD_MILLIS
                        ) {
                            focusSessionBreakCount += 1
                        }
                        sessionStartedAt = timestamp
                    }
                    val packageName = event.packageName ?: continue
                    activePackages[packageName] = timestamp
                }

                UsageEvents.Event.ACTIVITY_PAUSED,
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    val packageName = event.packageName ?: continue
                    val resumedAt = activePackages.remove(packageName) ?: continue
                    packageForegroundDurations[packageName] =
                        (packageForegroundDurations[packageName] ?: 0L) +
                            (timestamp - resumedAt).coerceAtLeast(0L)
                }

                UsageEvents.Event.DEVICE_SHUTDOWN -> {
                    interactiveStartedAt?.let { startedAt ->
                        screenOnDurationMillis += (timestamp - startedAt).coerceAtLeast(0L)
                    }
                    interactiveStartedAt = null
                    sessionStartedAt = closeSession(
                        sessionStartedAt = sessionStartedAt,
                        endedAt = timestamp,
                    ) { startedAt, endedAt ->
                        val duration = (endedAt - startedAt).coerceAtLeast(0L)
                        nighttimeUsageDurationMillis += nightOverlapMillis(startedAt, endedAt)
                        if (duration > longestContinuousUsageDurationMillis) {
                            longestContinuousUsageDurationMillis = duration
                            longestContinuousUsageStartedAtMillis = startedAt
                        }
                        lastSessionEndedAt = endedAt
                    }
                    closeForegroundPackages(
                        activePackages = activePackages,
                        packageForegroundDurations = packageForegroundDurations,
                        closedAt = timestamp,
                    )
                }
            }
        }

        interactiveStartedAt?.let { startedAt ->
            screenOnDurationMillis += (endMillis - startedAt).coerceAtLeast(0L)
        }
        closeSession(
            sessionStartedAt = sessionStartedAt,
            endedAt = endMillis,
        ) { startedAt, endedAt ->
            val duration = (endedAt - startedAt).coerceAtLeast(0L)
            nighttimeUsageDurationMillis += nightOverlapMillis(startedAt, endedAt)
            if (duration > longestContinuousUsageDurationMillis) {
                longestContinuousUsageDurationMillis = duration
                longestContinuousUsageStartedAtMillis = startedAt
            }
        }
        closeForegroundPackages(
            activePackages = activePackages,
            packageForegroundDurations = packageForegroundDurations,
            closedAt = endMillis,
        )
        mergeQueryUsageStats(
            usageStatsManager = usageStatsManager,
            startMillis = startMillis,
            endMillis = endMillis,
            packageForegroundDurations = packageForegroundDurations,
        )

        return AndroidUsageSummarySnapshot(
            dateKey = dateKey,
            screenOnDurationMillis = screenOnDurationMillis,
            unlockCount = unlockCount,
            viewCount = viewCount,
            nighttimeUsageDurationMillis = nighttimeUsageDurationMillis,
            focusSessionBreakCount = focusSessionBreakCount,
            longestContinuousUsageDurationMillis = longestContinuousUsageDurationMillis,
            longestContinuousUsageStartedAtMillis = longestContinuousUsageStartedAtMillis,
            topCategoryKey = resolveTopCategory(packageForegroundDurations),
        )
    }

    private fun mergeQueryUsageStats(
        usageStatsManager: UsageStatsManager,
        startMillis: Long,
        endMillis: Long,
        packageForegroundDurations: MutableMap<String, Long>,
    ) {
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startMillis,
            endMillis,
        )
        for (item in stats) {
            val packageName = item.packageName ?: continue
            val foregroundDuration = item.safeForegroundDuration()
            if (foregroundDuration <= 0L) {
                continue
            }
            if ((packageForegroundDurations[packageName] ?: 0L) <= 0L) {
                packageForegroundDurations[packageName] = foregroundDuration
            }
        }
    }

    private fun resolveTopCategory(packageForegroundDurations: Map<String, Long>): String {
        val topPackageName = packageForegroundDurations.maxByOrNull { it.value }?.key ?: return "unknown"
        val category = try {
            context.packageManager.getApplicationInfo(topPackageName, 0).category
        } catch (_: Throwable) {
            ApplicationInfo.CATEGORY_UNDEFINED
        }
        return when (category) {
            ApplicationInfo.CATEGORY_SOCIAL -> "social"
            ApplicationInfo.CATEGORY_VIDEO,
            ApplicationInfo.CATEGORY_IMAGE,
            ApplicationInfo.CATEGORY_AUDIO,
            -> "video"

            ApplicationInfo.CATEGORY_NEWS -> "reading"

            ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
            ApplicationInfo.CATEGORY_GAME,
            ApplicationInfo.CATEGORY_MAPS,
            ApplicationInfo.CATEGORY_UNDEFINED,
            -> "tools"

            else -> "unknown"
        }
    }

    private fun closeForegroundPackages(
        activePackages: MutableMap<String, Long>,
        packageForegroundDurations: MutableMap<String, Long>,
        closedAt: Long,
    ) {
        val entries = activePackages.toMap()
        activePackages.clear()
        entries.forEach { (packageName, startedAt) ->
            packageForegroundDurations[packageName] =
                (packageForegroundDurations[packageName] ?: 0L) +
                    (closedAt - startedAt).coerceAtLeast(0L)
        }
    }

    private fun closeSession(
        sessionStartedAt: Long?,
        endedAt: Long,
        onClosed: (startedAt: Long, endedAt: Long) -> Unit,
    ): Long? {
        sessionStartedAt?.let { startedAt ->
            onClosed(startedAt, endedAt)
        }
        return null
    }

    private fun nightOverlapMillis(startMillis: Long, endMillis: Long): Long {
        if (endMillis <= startMillis) {
            return 0L
        }

        val zoneId = ZoneId.systemDefault()
        var total = 0L
        var cursor = Instant.ofEpochMilli(startMillis).atZone(zoneId).toLocalDate()
        val endDate = Instant.ofEpochMilli(endMillis - 1).atZone(zoneId).toLocalDate()
        while (!cursor.isAfter(endDate)) {
            val nightStart = cursor.atTime(22, 0).atZone(zoneId).toInstant().toEpochMilli()
            val nightEnd = cursor.plusDays(1).atTime(6, 0).atZone(zoneId).toInstant().toEpochMilli()
            val overlapStart = max(startMillis, nightStart)
            val overlapEnd = minOf(endMillis, nightEnd)
            if (overlapEnd > overlapStart) {
                total += overlapEnd - overlapStart
            }
            cursor = cursor.plusDays(1)
        }
        return total
    }

    private fun hasUsageAccess(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return false
        }

        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
            ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOpsManager.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                context.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun AndroidUsageCapabilityStatus.canReadUsageStats(): Boolean {
        return isSupported && hasUsageAccess
    }

    private fun UsageStats.safeForegroundDuration(): Long {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            totalTimeVisible.takeIf { it > 0L } ?: totalTimeInForeground
        } else {
            totalTimeInForeground
        }
    }

    companion object {
        private const val SESSION_GAP_THRESHOLD_MILLIS = 15 * 60 * 1000L
    }
}
