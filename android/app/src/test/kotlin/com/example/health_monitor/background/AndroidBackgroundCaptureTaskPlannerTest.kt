package com.example.health_monitor.background

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AndroidBackgroundCaptureTaskPlannerTest {
    @Test
    fun resolveShouldClampCadenceToWorkManagerMinimum() {
        val planner = AndroidBackgroundCaptureTaskPlanner()
        val plan = planner.resolve(
            AndroidBackgroundCaptureRequest(
                notificationTitle = "健康监测正在后台运行",
                notificationBody = "用于持续积累活动、位置与用机样本。",
                enableMotion = true,
                enableLocation = true,
                enableNoise = false,
                enableDigitalUsage = true,
                sampleIntervalMinutes = 5,
            ),
        )

        assertEquals(15, plan.cadenceMinutes)
        assertTrue(plan.capabilityTags.contains(AndroidBackgroundCaptureTaskPlanner.CAPABILITY_MOTION))
        assertTrue(plan.capabilityTags.contains(AndroidBackgroundCaptureTaskPlanner.CAPABILITY_LOCATION))
        assertTrue(plan.capabilityTags.contains(AndroidBackgroundCaptureTaskPlanner.CAPABILITY_DIGITAL_USAGE))
    }
}
