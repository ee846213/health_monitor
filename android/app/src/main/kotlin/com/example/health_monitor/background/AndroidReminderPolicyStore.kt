package com.example.health_monitor.background

import android.content.SharedPreferences

/**
 * Flutter 侧将"勿扰窗口 + 提醒偏好"同步给原生通知通道时使用。
 *
 * 仅有原生侧的安全提醒（移动看屏）需要在 Flutter isolate 不在线时自行判断是否发送，
 * 因此把判断结果缓存到 SharedPreferences 中。所有字段都允许缺失，缺失时使用最宽松的默认值
 * （总开关默认开、勿扰默认关），保持与历史行为一致。
 */
class AndroidReminderPolicyStore(
    private val sharedPreferences: SharedPreferences,
) {
    fun update(snapshot: AndroidReminderPolicySnapshot) {
        sharedPreferences.edit()
            .putBoolean(KEY_MASTER_ENABLED, snapshot.masterEnabled)
            .putBoolean(KEY_WALKING_SCREEN_ENABLED, snapshot.walkingScreenEnabled)
            .putBoolean(KEY_DND_ENABLED, snapshot.dndEnabled)
            .putInt(KEY_DND_START_MINUTES, snapshot.dndStartMinutes)
            .putInt(KEY_DND_END_MINUTES, snapshot.dndEndMinutes)
            .apply()
    }

    fun shouldDeliverWalkingScreenReminder(nowMinutesOfDay: Int): Boolean {
        if (!sharedPreferences.getBoolean(KEY_MASTER_ENABLED, true)) {
            return false
        }
        if (!sharedPreferences.getBoolean(KEY_WALKING_SCREEN_ENABLED, true)) {
            return false
        }

        val dndEnabled = sharedPreferences.getBoolean(KEY_DND_ENABLED, false)
        if (!dndEnabled) {
            return true
        }

        val startMinutes = sharedPreferences.getInt(KEY_DND_START_MINUTES, 0)
        val endMinutes = sharedPreferences.getInt(KEY_DND_END_MINUTES, 0)
        if (startMinutes == endMinutes) {
            return true
        }

        // 与 Flutter 端 `NotificationPreference.isWithinWindow` 保持同样的跨午夜判定，
        // 避免两侧对同一时间点得出不一致的结果。
        return if (startMinutes < endMinutes) {
            !(nowMinutesOfDay in startMinutes until endMinutes)
        } else {
            !(nowMinutesOfDay >= startMinutes || nowMinutesOfDay < endMinutes)
        }
    }

    companion object {
        const val KEY_MASTER_ENABLED = "reminder_master_enabled"
        const val KEY_WALKING_SCREEN_ENABLED = "reminder_walking_screen_enabled"
        const val KEY_DND_ENABLED = "reminder_dnd_enabled"
        const val KEY_DND_START_MINUTES = "reminder_dnd_start_minutes"
        const val KEY_DND_END_MINUTES = "reminder_dnd_end_minutes"
    }
}

data class AndroidReminderPolicySnapshot(
    val masterEnabled: Boolean,
    val walkingScreenEnabled: Boolean,
    val dndEnabled: Boolean,
    val dndStartMinutes: Int,
    val dndEndMinutes: Int,
)
