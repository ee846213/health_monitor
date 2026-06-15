import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/rules/engine/activity_rules.dart';
import 'package:health_monitor/rules/engine/environment_rules.dart';
import 'package:health_monitor/rules/engine/posture_rules.dart';
import 'package:health_monitor/rules/engine/reminder_rules.dart';
import 'package:health_monitor/rules/engine/usage_rules.dart';
import 'package:health_monitor/rules/input/rule_input.dart';

Duration ms(int minutes) => Duration(minutes: minutes);

RuleInput _fullInput({
  List<ActivitySample> activities = const [],
  List<LocationSummary> locations = const [],
  List<NoiseSample> noises = const [],
  List<DigitalUsageSummary> usages = const [],
  List<DailyMetrics> metrics = const [],
}) {
  return RuleInput(
    window: QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 10)),
    activitySamples: activities,
    locationSummaries: locations,
    noiseSamples: noises,
    usageSummaries: usages,
    dailyMetricsList: metrics,
    missingDimensions: const [],
  );
}

void main() {
  final now = DateTime(2026, 6, 10);

  group('ActivityRule', () {
    const rule = ActivityRule();

    test('活动样本充足多样时应返回正常', () {
      final input = _fullInput(activities: <ActivitySample>[
        ActivitySample(capturedAt: now, duration: ms(15), type: ActivityType.walking, confidence: 0.8, stepCount: 500, source: MotionSampleSource.sensorFusion),
        ActivitySample(capturedAt: now, duration: ms(30), type: ActivityType.running, confidence: 0.9, stepCount: 2000, source: MotionSampleSource.sensorFusion),
        ActivitySample(capturedAt: now, duration: ms(45), type: ActivityType.cycling, confidence: 0.7, stepCount: 0, source: MotionSampleSource.sensorFusion),
      ]);
      final v = rule.evaluate(input);
      // 第一个 veredict 应该是正常结论。
      expect(v.where((x) => x.level == 'normal'), isNotEmpty);
      // 没有久坐警告。
      expect(v.where((x) => x.reminderType == 'sedentaryBreak'), isEmpty);
    });

    test('全静止样本应触发久坐提醒', () {
      final input = _fullInput(activities: <ActivitySample>[
        ActivitySample(capturedAt: now, duration: ms(65), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.reminderType == 'sedentaryBreak'), isNotEmpty);
    });

    test('步数不足应产出 warning', () {
      final input = _fullInput(activities: <ActivitySample>[
        ActivitySample(capturedAt: now, duration: ms(30), type: ActivityType.walking, confidence: 0.8, stepCount: 4200, source: MotionSampleSource.sensorFusion),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.level == 'warning'), isNotEmpty);
    });

    test('维度缺失时返回空', () {
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: now),
        activitySamples: const [],
        locationSummaries: const [],
        noiseSamples: const [],
        usageSummaries: const [],
        dailyMetricsList: const [],
        missingDimensions: const ['activity'],
      );
      expect(rule.evaluate(input), isEmpty);
    });
  });

  group('PostureRule', () {
    const rule = PostureRule();

    test('有两次长静止应触发姿势提醒', () {
      final input = _fullInput(activities: <ActivitySample>[
        ActivitySample(capturedAt: now, duration: ms(35), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion),
        ActivitySample(capturedAt: now.add(ms(50)), duration: ms(35), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion),
        ActivitySample(capturedAt: now.add(ms(100)), duration: ms(10), type: ActivityType.walking, confidence: 0.7, stepCount: 300, source: MotionSampleSource.sensorFusion),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.reminderType == 'postureRisk'), isNotEmpty);
    });

    test('行走占比高不再直接触发边走边看提醒', () {
      final samples = List<ActivitySample>.generate(6, (_) => ActivitySample(capturedAt: now, duration: ms(10), type: ActivityType.walking, confidence: 0.8, stepCount: 400, source: MotionSampleSource.sensorFusion));
      samples.addAll(List<ActivitySample>.generate(4, (_) => ActivitySample(capturedAt: now, duration: ms(10), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion)));
      final input = _fullInput(activities: samples);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.reminderType == 'walkingScreenRisk'), isEmpty);
    });
  });

  group('UsageRule', () {
    const rule = UsageRule();

    test('夜间看屏超阈值应触发提醒', () {
      final input = _fullInput(usages: <DigitalUsageSummary>[
        DigitalUsageSummary(date: DateTime(2026, 6, 10), screenOnDuration: ms(300), unlockCount: 30, nighttimeUsageDuration: ms(80), focusSessionBreakCount: 0, topCategory: UsageCategory.unknown),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.reminderType == 'nightUsage'), isNotEmpty);
    });

    test('屏幕使用正常且夜间时长不高时不触发提醒', () {
      final input = _fullInput(usages: <DigitalUsageSummary>[
        DigitalUsageSummary(date: DateTime(2026, 6, 10), screenOnDuration: ms(120), unlockCount: 30, nighttimeUsageDuration: ms(20), focusSessionBreakCount: 0, topCategory: UsageCategory.unknown),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.shouldRemind), isEmpty);
    });

    test('解锁次数超过阈值应产出 warning', () {
      final input = _fullInput(usages: <DigitalUsageSummary>[
        DigitalUsageSummary(date: DateTime(2026, 6, 10), screenOnDuration: ms(90), unlockCount: 40, nighttimeUsageDuration: ms(0), focusSessionBreakCount: 12, topCategory: UsageCategory.unknown),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.level == 'warning'), isNotEmpty);
    });
  });

  group('EnvironmentRule', () {
    const rule = EnvironmentRule();

    test('高噪音应触发提醒', () {
      final input = _fullInput(noises: <NoiseSample>[
        NoiseSample(capturedAt: now, duration: ms(1), decibel: 75, level: NoiseLevel.loud),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.reminderType == 'noisyEnvironment'), isNotEmpty);
    });

    test('正常噪音不触发提醒', () {
      final input = _fullInput(noises: <NoiseSample>[
        NoiseSample(capturedAt: now, duration: ms(1), decibel: 45, level: NoiseLevel.quiet),
      ]);
      final v = rule.evaluate(input);
      expect(v.where((x) => x.shouldRemind), isEmpty);
    });

    test('维度缺失时返回空', () {
      final input = RuleInput(
        window: QueryWindow.recentDay(referenceTime: now),
        activitySamples: const [],
        locationSummaries: const [],
        noiseSamples: const [],
        usageSummaries: const [],
        dailyMetricsList: const [],
        missingDimensions: const ['noise'],
      );
      expect(rule.evaluate(input), isEmpty);
    });
  });

  group('ReminderRule', () {
    test('应汇总所有触发提醒的规则结论并去重', () {
      final input = _fullInput(
        activities: List<ActivitySample>.generate(4, (_) => ActivitySample(capturedAt: now, duration: ms(60), type: ActivityType.stationary, confidence: 0.9, stepCount: 0, source: MotionSampleSource.sensorFusion)),
        noises: <NoiseSample>[NoiseSample(capturedAt: now, duration: ms(1), decibel: 75, level: NoiseLevel.loud)],
        metrics: <DailyMetrics>[
          DailyMetrics(
            date: now,
            stepCount: 0,
            sedentaryDuration: ms(240),
            screenOnDuration: Duration.zero,
            outdoorDuration: Duration.zero,
            postureRiskCount: 2,
            highNoiseExposureDuration: ms(1),
          ),
        ],
      );

      final rule = ReminderRule(sourceRules: const [
        ActivityRule(),
        PostureRule(),
        EnvironmentRule(),
      ]);

      final reminders = rule.evaluate(input);

      // 应有 sedentaryBreak + postureRisk + noisyEnvironment 三个提醒
      expect(reminders.where((x) => x.reminderType == 'sedentaryBreak'), isNotEmpty);
      expect(reminders.where((x) => x.reminderType == 'postureRisk'), isNotEmpty);
      expect(reminders.where((x) => x.reminderType == 'noisyEnvironment'), isNotEmpty);
      // 去重测试: sedentaryBreak 应只出现一次
      expect(reminders.where((x) => x.reminderType == 'sedentaryBreak').length, 1);
    });
  });
}
