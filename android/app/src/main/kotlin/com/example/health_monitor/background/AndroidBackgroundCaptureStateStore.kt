package com.example.health_monitor.background

import android.content.SharedPreferences

data class AndroidBackgroundCaptureState(
    val activeRequest: AndroidBackgroundCaptureRequest? = null,
    val lastErrorMessage: String? = null,
    val lastSummary: String = "Android 后台采集尚未启动。",
)

interface AndroidBackgroundCaptureStateStore {
    fun read(): AndroidBackgroundCaptureState

    fun write(state: AndroidBackgroundCaptureState)
}

class InMemoryAndroidBackgroundCaptureStateStore : AndroidBackgroundCaptureStateStore {
    private var state: AndroidBackgroundCaptureState = AndroidBackgroundCaptureState()

    override fun read(): AndroidBackgroundCaptureState {
        return state
    }

    override fun write(state: AndroidBackgroundCaptureState) {
        this.state = state
    }
}

class SharedPreferencesAndroidBackgroundCaptureStateStore(
    private val sharedPreferences: SharedPreferences,
) : AndroidBackgroundCaptureStateStore {
    override fun read(): AndroidBackgroundCaptureState {
        val activeRequest = sharedPreferences.getString(KEY_ACTIVE_REQUEST, null)
            ?.let(AndroidBackgroundCaptureRequestCodec::decode)
        return AndroidBackgroundCaptureState(
            activeRequest = activeRequest,
            lastErrorMessage = sharedPreferences.getString(KEY_LAST_ERROR, null),
            lastSummary = sharedPreferences.getString(KEY_LAST_SUMMARY, DEFAULT_SUMMARY)
                ?: DEFAULT_SUMMARY,
        )
    }

    override fun write(state: AndroidBackgroundCaptureState) {
        sharedPreferences.edit()
            .putString(KEY_ACTIVE_REQUEST, state.activeRequest?.let(AndroidBackgroundCaptureRequestCodec::encode))
            .putString(KEY_LAST_ERROR, state.lastErrorMessage)
            .putString(KEY_LAST_SUMMARY, state.lastSummary)
            .apply()
    }

    companion object {
        private const val DEFAULT_SUMMARY = "Android 后台采集尚未启动。"
        private const val KEY_ACTIVE_REQUEST = "android_background_active_request"
        private const val KEY_LAST_ERROR = "android_background_last_error"
        private const val KEY_LAST_SUMMARY = "android_background_last_summary"
    }
}
