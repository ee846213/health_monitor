import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/usage/screen_usage_habit_summary.dart';
import 'package:health_monitor/features/briefing/briefing_suggestion_builder.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

void main() {
  test('简报建议会优先覆盖活动久坐屏幕和环境噪音', () {
    final suggestions = buildBriefingSuggestions(
      HealthInsightSnapshot(
        input: RuleInput(
          window:
              QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 19, 9)),
          activitySamples: const <ActivitySample>[],
          locationSummaries: const [],
          noiseSamples: const [],
          ambientLightSamples: const [],
          usageSummaries: const [],
          dailyMetricsList: const [],
          missingDimensions: const <String>[],
        ),
        verdicts: const [],
        metrics: const HealthInsightMetrics(
          stepCount: 3600,
          sedentaryMinutes: 150,
          screenMinutes: 220,
          outdoorMinutes: 18,
        ),
        environmentOverview: const EnvironmentOverview(
          headline: '夜间环境偏嘈杂',
          detail: '夜间连续嘈杂时段偏长。',
          daytimeLightSummary: '白天舒适',
          nightNoiseSummary: '夜间嘈杂 48 分钟',
          primaryConcern: EnvironmentPrimaryConcern.highNoise,
        ),
        screenUsageHabitSummary: const ScreenUsageHabitSummary(
          headline: '查看频率偏高',
          supportingDetail: '最近平均每天查看 42 次。',
          checkingFrequencyLevel: UsageHabitLevel.high,
          nightUsageLevel: UsageHabitLevel.elevated,
          activationDensityLevel: UsageHabitLevel.high,
          longestSessionMinutes: 28,
          sourceLabel: '测试数据',
          qualityNote: null,
        ),
        generatedReminders: const [],
        reminderHistory: const [],
        hasRealData: true,
      ),
    );

    expect(suggestions, hasLength(4));
    expect(suggestions[0], contains('活动量'));
    expect(suggestions[1], contains('久坐'));
    expect(suggestions[2], anyOf(contains('查看'), contains('屏幕')));
    expect(suggestions[3], contains('噪音'));
  });

  test('简报建议在没有明显问题时给出稳定维持建议', () {
    final suggestions = buildBriefingSuggestions(
      HealthInsightSnapshot(
        input: RuleInput(
          window:
              QueryWindow.recentDay(referenceTime: DateTime(2026, 6, 19, 9)),
          activitySamples: const <ActivitySample>[],
          locationSummaries: const [],
          noiseSamples: const [],
          ambientLightSamples: const [],
          usageSummaries: const [],
          dailyMetricsList: const [],
          missingDimensions: const <String>[],
        ),
        verdicts: const [],
        metrics: const HealthInsightMetrics(
          stepCount: 7600,
          sedentaryMinutes: 80,
          screenMinutes: 90,
          outdoorMinutes: 25,
        ),
        environmentOverview: const EnvironmentOverview(
          headline: '环境整体平稳',
          detail: '白天光线和夜间噪音都比较稳定。',
          daytimeLightSummary: '白天舒适',
          nightNoiseSummary: '夜间安静',
          primaryConcern: EnvironmentPrimaryConcern.none,
        ),
        screenUsageHabitSummary: null,
        generatedReminders: const [],
        reminderHistory: const [],
        hasRealData: true,
      ),
    );

    expect(suggestions, hasLength(1));
    expect(suggestions.single, contains('步数'));
    expect(suggestions.single, contains('久坐'));
  });
}
