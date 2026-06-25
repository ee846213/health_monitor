import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/dashboard_service.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  final reference = DateTime(2026, 6, 22, 17, 30);

  DashboardService buildService() {
    return DashboardService(
      loadInsightSnapshot: ({required window, referenceTime}) async {
        throw UnimplementedError('测试直接调用 buildFromInsight');
      },
      buildDailyAdvice: ({
        required referenceTime,
        required input,
        required metrics,
        required verdicts,
        required environmentOverview,
      }) async {
        return const DailyAdviceBubble(
          text: 'fallback',
          source: DailyAdviceSource.fallback,
        );
      },
    );
  }

  HealthInsightSnapshot insightWith({
    List<ActivitySample> activitySamples = const <ActivitySample>[],
    List<NoiseSample> noiseSamples = const <NoiseSample>[],
    List<DigitalUsageSummary> usageSummaries = const <DigitalUsageSummary>[],
    List<DailyMetrics> dailyMetricsList = const <DailyMetrics>[],
    int stepCount = 0,
  }) {
    final input = RuleInput(
      window: QueryWindow.recentDay(referenceTime: reference),
      activitySamples: activitySamples,
      locationSummaries: const [],
      noiseSamples: noiseSamples,
      usageSummaries: usageSummaries,
      dailyMetricsList: dailyMetricsList,
      missingDimensions: const [],
    );
    return HealthInsightSnapshot(
      input: input,
      verdicts: const [],
      metrics: HealthInsightMetrics(
        stepCount: stepCount,
        sedentaryMinutes: 0,
        screenMinutes: 0,
        outdoorMinutes: 0,
      ),
      environmentOverview: null,
      screenUsageHabitSummary: null,
      generatedReminders: const [],
      reminderHistory: const [],
      hasRealData: activitySamples.isNotEmpty ||
          noiseSamples.isNotEmpty ||
          usageSummaries.isNotEmpty,
    );
  }

  test('活动节点时刻应落在当日步数最高的可信运动样本上', () async {
    final peakAt = DateTime(2026, 6, 22, 16, 20);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        activitySamples: <ActivitySample>[
          ActivitySample(
            capturedAt: DateTime(2026, 6, 22, 8),
            duration: const Duration(minutes: 10),
            type: ActivityType.walking,
            confidence: 0.9,
            stepCount: 200,
            source: MotionSampleSource.sensorFusion,
          ),
          ActivitySample(
            capturedAt: peakAt,
            duration: const Duration(minutes: 12),
            type: ActivityType.walking,
            confidence: 0.95,
            stepCount: 900,
            source: MotionSampleSource.sensorFusion,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, peakAt);
    expect(snapshot.rhythmSignals.activityPeakSteps, 900);
  });

  test('无逐步数时应退化为最长连续走/跑片段起点', () async {
    final segmentStart = DateTime(2026, 6, 22, 11, 5);
    final walkingSamples = List<ActivitySample>.generate(
      150,
      (int index) => ActivitySample(
        capturedAt: segmentStart.add(Duration(seconds: index)),
        duration: const Duration(seconds: 1),
        type: ActivityType.walking,
        confidence: 0.9,
        stepCount: 0,
        source: MotionSampleSource.sensorFusion,
      ),
    );
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(activitySamples: walkingSamples),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, segmentStart);
    expect(snapshot.rhythmSignals.activityPeakSteps, greaterThanOrEqualTo(200));
  });

  test('系统计步增量样本应提供可定位的活跃时刻', () async {
    final peakAt = DateTime(2026, 6, 22, 12, 10);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        activitySamples: <ActivitySample>[
          ActivitySample(
            capturedAt: peakAt,
            duration: const Duration(seconds: 1),
            type: ActivityType.walking,
            confidence: 0.85,
            stepCount: 860,
            source: MotionSampleSource.platformActivity,
          ),
          ActivitySample(
            capturedAt: DateTime(2026, 6, 22, 18),
            duration: const Duration(seconds: 1),
            type: ActivityType.walking,
            confidence: 0.85,
            stepCount: 240,
            source: MotionSampleSource.platformActivity,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, peakAt);
    expect(snapshot.rhythmSignals.activityPeakSteps, 860);
  });

  test('当日总步数达标时应退化为走跑最集中的小时', () async {
    final walkingSamples = List<ActivitySample>.generate(
      90,
      (int index) => ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 8, 10).add(Duration(seconds: index)),
        duration: const Duration(seconds: 1),
        type: ActivityType.walking,
        confidence: 0.9,
        stepCount: 0,
        source: MotionSampleSource.sensorFusion,
      ),
    );
    final input = RuleInput(
      window: QueryWindow.recentDay(referenceTime: reference),
      activitySamples: walkingSamples,
      locationSummaries: const [],
      noiseSamples: const [],
      usageSummaries: const [],
      dailyMetricsList: <DailyMetrics>[
        DailyMetrics(
          date: DateTime(2026, 6, 22),
          stepCount: 5163,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        ),
      ],
      missingDimensions: const [],
    );
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: HealthInsightSnapshot(
        input: input,
        verdicts: const [],
        metrics: const HealthInsightMetrics(
          stepCount: 5163,
          sedentaryMinutes: 0,
          screenMinutes: 0,
          outdoorMinutes: 0,
        ),
        environmentOverview: null,
        screenUsageHabitSummary: null,
        generatedReminders: const [],
        reminderHistory: const [],
        hasRealData: true,
      ),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, DateTime(2026, 6, 22, 8));
    expect(snapshot.rhythmSignals.activityPeakSteps, 5163);
  });

  test('Health Connect 小时步数应提供可定位的活跃时刻', () async {
    final peakAt = DateTime(2026, 6, 22, 8);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        activitySamples: <ActivitySample>[
          ActivitySample(
            capturedAt: peakAt,
            duration: const Duration(hours: 1),
            type: ActivityType.walking,
            confidence: 0.85,
            stepCount: 3200,
            source: MotionSampleSource.healthConnectHourly,
          ),
          ActivitySample(
            capturedAt: DateTime(2026, 6, 22, 18),
            duration: const Duration(hours: 1),
            type: ActivityType.walking,
            confidence: 0.85,
            stepCount: 900,
            source: MotionSampleSource.healthConnectHourly,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, peakAt);
    expect(snapshot.rhythmSignals.activityPeakSteps, 3200);
  });

  test('步数达标但缺少逐步数样本时应退化为活动集中时段', () async {
    final walkingSamples = List<ActivitySample>.generate(
      90,
      (int index) => ActivitySample(
        capturedAt: DateTime(2026, 6, 22, 8, 10).add(Duration(seconds: index)),
        duration: const Duration(seconds: 1),
        type: ActivityType.walking,
        confidence: 0.9,
        stepCount: 0,
        source: MotionSampleSource.sensorFusion,
      ),
    );
    final input = RuleInput(
      window: QueryWindow.recentDay(referenceTime: reference),
      activitySamples: walkingSamples,
      locationSummaries: const [],
      noiseSamples: const [],
      usageSummaries: const [],
      dailyMetricsList: <DailyMetrics>[
        DailyMetrics(
          date: DateTime(2026, 6, 22),
          stepCount: 6200,
          sedentaryDuration: Duration.zero,
          screenOnDuration: Duration.zero,
          outdoorDuration: Duration.zero,
          postureRiskCount: 0,
          highNoiseExposureDuration: Duration.zero,
        ),
      ],
      missingDimensions: const [],
    );
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: HealthInsightSnapshot(
        input: input,
        verdicts: const [],
        metrics: const HealthInsightMetrics(
          stepCount: 6200,
          sedentaryMinutes: 0,
          screenMinutes: 0,
          outdoorMinutes: 0,
        ),
        environmentOverview: null,
        screenUsageHabitSummary: null,
        generatedReminders: const [],
        reminderHistory: const [],
        hasRealData: true,
      ),
    );

    expect(snapshot.rhythmSignals.stepGoalReachedAt, DateTime(2026, 6, 22, 8));
    expect(snapshot.rhythmSignals.stepGoalReachedIsPrecise, isFalse);
    expect(snapshot.rhythmSignals.stepGoalReachedAt, isNot(reference));
  });

  test('步数达标时刻应落在累计首次达到目标的逐步数样本上', () async {
    final goalReachedAt = DateTime(2026, 6, 22, 15, 20);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        activitySamples: <ActivitySample>[
          ActivitySample(
            capturedAt: DateTime(2026, 6, 22, 9),
            duration: const Duration(seconds: 1),
            type: ActivityType.walking,
            confidence: 0.9,
            stepCount: 3200,
            source: MotionSampleSource.platformActivity,
          ),
          ActivitySample(
            capturedAt: DateTime(2026, 6, 22, 12),
            duration: const Duration(seconds: 1),
            type: ActivityType.walking,
            confidence: 0.9,
            stepCount: 2500,
            source: MotionSampleSource.platformActivity,
          ),
          ActivitySample(
            capturedAt: goalReachedAt,
            duration: const Duration(seconds: 1),
            type: ActivityType.walking,
            confidence: 0.9,
            stepCount: 500,
            source: MotionSampleSource.platformActivity,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.stepGoalReachedAt, goalReachedAt);
    expect(snapshot.rhythmSignals.stepGoalReachedIsPrecise, isTrue);
  });

  test('只有今日总步数达标时应生成非精确活动与达标节点信号', () async {
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        dailyMetricsList: <DailyMetrics>[
          DailyMetrics(
            date: DateTime(2026, 6, 22),
            stepCount: 10086,
            sedentaryDuration: Duration.zero,
            screenOnDuration: Duration.zero,
            outdoorDuration: Duration.zero,
            postureRiskCount: 0,
            highNoiseExposureDuration: Duration.zero,
          ),
        ],
        stepCount: 10086,
      ),
    );

    expect(
        snapshot.rhythmSignals.activityPeakAt, DateTime(2026, 6, 22, 17, 30));
    expect(snapshot.rhythmSignals.activityPeakSteps, 10086);
    expect(snapshot.rhythmSignals.activityPeakIsPrecise, isFalse);
    expect(snapshot.rhythmSignals.stepGoalReachedAt,
        DateTime(2026, 6, 22, 17, 30));
    expect(snapshot.rhythmSignals.stepGoalReachedIsPrecise, isFalse);
  });

  test('环境节点时刻应落在当日分贝最高的噪音样本上', () async {
    final loudAt = DateTime(2026, 6, 22, 13, 5);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        noiseSamples: <NoiseSample>[
          NoiseSample.fromDecibel(
            capturedAt: DateTime(2026, 6, 22, 9),
            duration: const Duration(minutes: 1),
            decibel: 42,
          ),
          NoiseSample.fromDecibel(
            capturedAt: loudAt,
            duration: const Duration(minutes: 1),
            decibel: 78,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.noisePeakAt, loudAt);
    expect(snapshot.rhythmSignals.noisePeakDecibel, 78);
  });

  test('数字习惯节点应落在当日最长连续使用片段的真实起点上', () async {
    final sessionStart = DateTime(2026, 6, 22, 20, 40);
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        usageSummaries: <DigitalUsageSummary>[
          DigitalUsageSummary(
            date: DateTime(2026, 6, 22),
            screenOnDuration: const Duration(minutes: 120),
            unlockCount: 30,
            nighttimeUsageDuration: const Duration(minutes: 15),
            focusSessionBreakCount: 3,
            topCategory: UsageCategory.social,
            viewCount: 30,
            longestContinuousUsageDuration: const Duration(minutes: 42),
            longestContinuousUsageStartedAt: sessionStart,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.digitalUsageAt, sessionStart);
    expect(snapshot.rhythmSignals.digitalUsageIsPrecise, isTrue);
    expect(snapshot.rhythmSignals.digitalLongestSessionMinutes, 42);
  });

  test('同日多条 usage 摘要累计亮屏应取合并值而非相加', () async {
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        usageSummaries: <DigitalUsageSummary>[
          DigitalUsageSummary(
            date: DateTime(2026, 6, 22),
            screenOnDuration: const Duration(minutes: 120),
            unlockCount: 30,
            nighttimeUsageDuration: const Duration(minutes: 15),
            focusSessionBreakCount: 3,
            topCategory: UsageCategory.social,
            viewCount: 30,
            longestContinuousUsageDuration: const Duration(minutes: 42),
          ),
          DigitalUsageSummary(
            date: DateTime(2026, 6, 22),
            screenOnDuration: const Duration(minutes: 90),
            unlockCount: 20,
            nighttimeUsageDuration: const Duration(minutes: 10),
            focusSessionBreakCount: 2,
            topCategory: UsageCategory.video,
            viewCount: 20,
            longestContinuousUsageDuration: const Duration(minutes: 35),
            longestContinuousUsageStartedAt: DateTime(2026, 6, 22, 20, 40),
          ),
        ],
      ),
    );

    expect(snapshot.screenCard.totalMinutes, 120);
    expect(snapshot.screenCard.longestSingleMinutes, 42);
    expect(snapshot.rhythmSignals.digitalUsageIsPrecise, isFalse);
  });

  test('数字习惯仅有按日聚合且夜间偏长时退化到夜间代表时刻', () async {
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(
        usageSummaries: <DigitalUsageSummary>[
          DigitalUsageSummary(
            date: DateTime(2026, 6, 22),
            screenOnDuration: const Duration(minutes: 90),
            unlockCount: 20,
            nighttimeUsageDuration: const Duration(minutes: 45),
            focusSessionBreakCount: 2,
            topCategory: UsageCategory.video,
            viewCount: 20,
          ),
        ],
      ),
    );

    expect(snapshot.rhythmSignals.digitalUsageAt, DateTime(2026, 6, 22, 22));
    expect(snapshot.rhythmSignals.digitalUsageIsPrecise, isFalse);
    expect(snapshot.rhythmSignals.digitalLongestSessionMinutes, isNull);
  });

  test('缺乏可定位样本时节奏信号应保持为空', () async {
    final snapshot = await buildService().buildFromInsight(
      referenceTime: reference,
      insight: insightWith(),
    );

    expect(snapshot.rhythmSignals.activityPeakAt, isNull);
    expect(snapshot.rhythmSignals.sedentaryStartAt, isNull);
    expect(snapshot.rhythmSignals.noisePeakAt, isNull);
    expect(snapshot.rhythmSignals.digitalUsageAt, isNull);
  });
}
