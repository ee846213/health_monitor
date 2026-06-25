package com.example.health_monitor.healthconnect

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.AggregateGroupByDurationRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Duration
import java.time.Instant
import kotlinx.coroutines.runBlocking

/**
 * 从 Health Connect 读取按小时聚合的步数，用于晚开 App 时还原活动集中时段。
 */
class AndroidHealthConnectReader(
    private val context: Context,
) {
    fun getStatus(): Map<String, Any?> {
        val sdkStatus = HealthConnectClient.getSdkStatus(context)
        val isAvailable = sdkStatus == HealthConnectClient.SDK_AVAILABLE
        val client = if (isAvailable) {
            runCatching { HealthConnectClient.getOrCreate(context) }.getOrNull()
        } else {
            null
        }
        val hasPermission = if (client != null) {
            runBlocking {
                runCatching {
                    client.permissionController.getGrantedPermissions()
                        .containsAll(STEP_READ_PERMISSIONS)
                }.getOrDefault(false)
            }
        } else {
            false
        }
        return mapOf<String, Any?>(
            "sdkStatus" to sdkStatus,
            "isAvailable" to isAvailable,
            "hasStepsPermission" to hasPermission,
            "needsInstall" to (sdkStatus == HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED),
        )
    }

    fun readHourlySteps(startMillis: Long, endMillis: Long): List<HourlyStepBucket> {
        if (HealthConnectClient.getSdkStatus(context) != HealthConnectClient.SDK_AVAILABLE) {
            return emptyList()
        }
        val client = runCatching { HealthConnectClient.getOrCreate(context) }.getOrNull()
            ?: return emptyList()
        return runBlocking {
            runCatching {
                val granted = client.permissionController.getGrantedPermissions()
                if (!granted.containsAll(STEP_READ_PERMISSIONS)) {
                    return@runBlocking emptyList()
                }
                val response = client.aggregateGroupByDuration(
                    AggregateGroupByDurationRequest(
                        metrics = setOf(StepsRecord.COUNT_TOTAL),
                        timeRangeFilter = TimeRangeFilter.between(
                            Instant.ofEpochMilli(startMillis),
                            Instant.ofEpochMilli(endMillis),
                        ),
                        timeRangeSlicer = Duration.ofHours(1),
                    ),
                )
                response.mapNotNull { bucket ->
                    val steps = bucket.result[StepsRecord.COUNT_TOTAL]?.toLong()?.toInt() ?: 0
                    if (steps <= 0) {
                        null
                    } else {
                        HourlyStepBucket(
                            startMillis = bucket.startTime.toEpochMilli(),
                            endMillis = bucket.endTime.toEpochMilli(),
                            stepCount = steps,
                        )
                    }
                }
            }.getOrDefault(emptyList())
        }
    }

    fun openHealthConnectSettings(): Boolean {
        val intent = Intent(HealthConnectClient.ACTION_HEALTH_CONNECT_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return runCatching {
            context.startActivity(intent)
            true
        }.getOrElse {
            val marketIntent = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("market://details?id=com.google.android.apps.healthdata"),
            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            runCatching {
                context.startActivity(marketIntent)
                true
            }.getOrDefault(false)
        }
    }

    companion object {
        private val STEP_READ_PERMISSIONS = setOf(
            HealthPermission.getReadPermission(StepsRecord::class),
        )
    }

    fun canReadHourlySteps(): Boolean {
        val status = getStatus()
        return status["isAvailable"] == true && status["hasStepsPermission"] == true
    }

    fun stepReadPermissions(): Set<String> = STEP_READ_PERMISSIONS

    fun createPermissionContract() =
        PermissionController.createRequestPermissionResultContract()
}
