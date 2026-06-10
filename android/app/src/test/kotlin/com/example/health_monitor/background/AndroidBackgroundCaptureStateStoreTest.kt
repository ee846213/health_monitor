package com.example.health_monitor.background

import android.content.SharedPreferences
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class AndroidBackgroundCaptureStateStoreTest {
    @Test
    fun sharedPreferencesStoreShouldPersistAndReadBackState() {
        val prefs = InMemorySharedPreferences()
        val store = SharedPreferencesAndroidBackgroundCaptureStateStore(prefs)
        val request = AndroidBackgroundCaptureRequest(
            notificationTitle = "健康监测正在后台运行",
            notificationBody = "用于持续积累活动、位置与用机样本。",
            enableMotion = true,
            enableLocation = true,
            enableNoise = false,
            enableDigitalUsage = true,
            sampleIntervalMinutes = 15,
        )

        store.write(
            AndroidBackgroundCaptureState(
                activeRequest = request,
                lastErrorMessage = "前台服务启动失败",
                lastSummary = "Android 后台采集出现异常：前台服务启动失败",
            ),
        )

        val state = store.read()

        assertNotNull(state.activeRequest)
        assertEquals(request, state.activeRequest)
        assertEquals("前台服务启动失败", state.lastErrorMessage)
        assertEquals("Android 后台采集出现异常：前台服务启动失败", state.lastSummary)
    }
}

private class InMemorySharedPreferences : SharedPreferences {
    private val data = mutableMapOf<String, String?>()

    override fun getAll(): MutableMap<String, *> = data.toMutableMap()

    override fun getString(key: String?, defValue: String?): String? = data[key] ?: defValue

    override fun edit(): SharedPreferences.Editor = EditorImpl(data)

    override fun getStringSet(key: String?, defValues: MutableSet<String>?): MutableSet<String>? = defValues

    override fun getInt(key: String?, defValue: Int): Int = defValue
    override fun getLong(key: String?, defValue: Long): Long = defValue
    override fun getFloat(key: String?, defValue: Float): Float = defValue
    override fun getBoolean(key: String?, defValue: Boolean): Boolean = defValue
    override fun contains(key: String?): Boolean = data.containsKey(key)
    override fun registerOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener?) = Unit
    override fun unregisterOnSharedPreferenceChangeListener(listener: SharedPreferences.OnSharedPreferenceChangeListener?) = Unit
}

private class EditorImpl(
    private val data: MutableMap<String, String?>,
) : SharedPreferences.Editor {
    override fun putString(key: String?, value: String?): SharedPreferences.Editor {
        if (key != null) {
            data[key] = value
        }
        return this
    }

    override fun apply() = Unit
    override fun commit(): Boolean = true
    override fun clear(): SharedPreferences.Editor {
        data.clear()
        return this
    }

    override fun remove(key: String?): SharedPreferences.Editor {
        if (key != null) {
            data.remove(key)
        }
        return this
    }

    override fun putBoolean(key: String?, value: Boolean): SharedPreferences.Editor = this
    override fun putFloat(key: String?, value: Float): SharedPreferences.Editor = this
    override fun putInt(key: String?, value: Int): SharedPreferences.Editor = this
    override fun putLong(key: String?, value: Long): SharedPreferences.Editor = this
    override fun putStringSet(key: String?, values: MutableSet<String>?): SharedPreferences.Editor = this
}
