package plugins.cachet.audio_streamer

import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35])
class EventSinkDispatcherTest {

    @Test
    fun `dispatches error callback on main thread before notifying Flutter`() {
        val sink = RecordingEventSink()
        val dispatcher = EventSinkDispatcher(sink)
        val workerThreadName = "worker-thread"

        Thread {
            dispatcher.error(
                code = "MIC_ERROR",
                message = "record failed",
                details = null,
            )
        }.apply {
            name = workerThreadName
            start()
            join()
        }

        Shadows.shadowOf(Looper.getMainLooper()).idle()

        assertTrue(sink.awaitError())
        assertEquals("MIC_ERROR", sink.errorCode)
        assertNotEquals(workerThreadName, sink.callbackThreadName)
    }
}

private class RecordingEventSink : EventChannel.EventSink {
    private val errorLatch = CountDownLatch(1)

    var callbackThreadName: String? = null
    var errorCode: String? = null

    override fun success(event: Any?) = Unit

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        callbackThreadName = Thread.currentThread().name
        this.errorCode = errorCode
        errorLatch.countDown()
    }

    override fun endOfStream() = Unit

    fun awaitError(): Boolean {
        return errorLatch.await(1, TimeUnit.SECONDS)
    }
}
