package com.example.health_monitor.background

import android.content.SharedPreferences
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidReminderPolicyStoreTest {
    @Test
    fun unconfiguredStoreShouldAllowWalkingScreenReminder() {
        val store = AndroidReminderPolicyStore(InMemoryBooleanIntPrefs())

        // 默认状态下未写入任何字段，应保持与历史行为一致：允许投递。
        assertTrue(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 9 * 60))
    }

    @Test
    fun masterDisabledShouldBlockAllReminders() {
        val prefs = InMemoryBooleanIntPrefs()
        val store = AndroidReminderPolicyStore(prefs)

        store.update(
            AndroidReminderPolicySnapshot(
                masterEnabled = false,
                walkingScreenEnabled = true,
                dndEnabled = false,
                dndStartMinutes = 0,
                dndEndMinutes = 0,
            ),
        )

        assertFalse(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 9 * 60))
    }

    @Test
    fun walkingScreenCategoryDisabledShouldBlockEvenWhenMasterEnabled() {
        val store = AndroidReminderPolicyStore(InMemoryBooleanIntPrefs())
        store.update(
            AndroidReminderPolicySnapshot(
                masterEnabled = true,
                walkingScreenEnabled = false,
                dndEnabled = false,
                dndStartMinutes = 0,
                dndEndMinutes = 0,
            ),
        )

        assertFalse(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 9 * 60))
    }

    @Test
    fun dndWindowShouldBlockReminderInsideAndAllowOutside() {
        val store = AndroidReminderPolicyStore(InMemoryBooleanIntPrefs())
        store.update(
            AndroidReminderPolicySnapshot(
                masterEnabled = true,
                walkingScreenEnabled = true,
                dndEnabled = true,
                dndStartMinutes = 22 * 60 + 30,
                dndEndMinutes = 7 * 60,
            ),
        )

        // 跨午夜窗口：23:00 与 03:00 都在窗口内，应被屏蔽。
        assertFalse(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 23 * 60))
        assertFalse(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 3 * 60))
        // 9:00 在窗口外，应允许。
        assertTrue(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 9 * 60))
    }

    @Test
    fun sameDayDndWindowShouldOnlyBlockInside() {
        val store = AndroidReminderPolicyStore(InMemoryBooleanIntPrefs())
        store.update(
            AndroidReminderPolicySnapshot(
                masterEnabled = true,
                walkingScreenEnabled = true,
                dndEnabled = true,
                dndStartMinutes = 13 * 60,
                dndEndMinutes = 14 * 60,
            ),
        )

        assertFalse(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 13 * 60 + 30))
        assertTrue(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 14 * 60))
        assertTrue(store.shouldDeliverWalkingScreenReminder(nowMinutesOfDay = 12 * 60 + 59))
    }
}

private class InMemoryBooleanIntPrefs : SharedPreferences {
    private val booleans = mutableMapOf<String, Boolean>()
    private val ints = mutableMapOf<String, Int>()

    override fun getAll(): MutableMap<String, *> = (booleans + ints).toMutableMap()
    override fun getString(key: String?, defValue: String?): String? = defValue
    override fun getStringSet(
        key: String?,
        defValues: MutableSet<String>?,
    ): MutableSet<String>? = defValues

    override fun getInt(key: String?, defValue: Int): Int =
        if (key != null && ints.containsKey(key)) ints[key]!! else defValue

    override fun getLong(key: String?, defValue: Long): Long = defValue
    override fun getFloat(key: String?, defValue: Float): Float = defValue

    override fun getBoolean(key: String?, defValue: Boolean): Boolean =
        if (key != null && booleans.containsKey(key)) booleans[key]!! else defValue

    override fun contains(key: String?): Boolean =
        booleans.containsKey(key) || ints.containsKey(key)

    override fun edit(): SharedPreferences.Editor = Editor(booleans, ints)
    override fun registerOnSharedPreferenceChangeListener(
        listener: SharedPreferences.OnSharedPreferenceChangeListener?,
    ) = Unit

    override fun unregisterOnSharedPreferenceChangeListener(
        listener: SharedPreferences.OnSharedPreferenceChangeListener?,
    ) = Unit

    private class Editor(
        private val booleans: MutableMap<String, Boolean>,
        private val ints: MutableMap<String, Int>,
    ) : SharedPreferences.Editor {
        override fun putBoolean(key: String?, value: Boolean): SharedPreferences.Editor {
            if (key != null) booleans[key] = value
            return this
        }

        override fun putInt(key: String?, value: Int): SharedPreferences.Editor {
            if (key != null) ints[key] = value
            return this
        }

        override fun apply() = Unit
        override fun commit(): Boolean = true
        override fun clear(): SharedPreferences.Editor {
            booleans.clear(); ints.clear(); return this
        }

        override fun remove(key: String?): SharedPreferences.Editor {
            if (key != null) {
                booleans.remove(key); ints.remove(key)
            }
            return this
        }

        override fun putString(key: String?, value: String?): SharedPreferences.Editor = this
        override fun putStringSet(
            key: String?,
            values: MutableSet<String>?,
        ): SharedPreferences.Editor = this

        override fun putFloat(key: String?, value: Float): SharedPreferences.Editor = this
        override fun putLong(key: String?, value: Long): SharedPreferences.Editor = this
    }
}
