import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/domain/environment/ambient_light_sample.dart';
import 'package:health_monitor/domain/environment/noise_sample.dart';
import 'package:health_monitor/domain/location/location_summary.dart';
import 'package:health_monitor/domain/metrics/daily_metrics.dart';
import 'package:health_monitor/domain/motion/activity_sample.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/domain/usage/digital_usage_summary.dart';
import 'package:health_monitor/features/overview/pages/overview_page.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/activity_repository.dart';
import 'package:health_monitor/storage/repositories/metrics_repository.dart';
import 'package:health_monitor/storage/repositories/usage_summary_repository.dart';

void main() {
  testWidgets('步数卡片弹层展示 7 天柱状图', (WidgetTester tester) async {
    final now = DateTime.now();
    final baseDay = DateTime(now.year, now.month, now.day);
    final metrics = List<DailyMetrics>.generate(7, (int index) {
      final day = baseDay.subtract(Duration(days: 6 - index));
      return DailyMetrics(
        date: day,
        stepCount: 3200 + index * 500,
        sedentaryDuration: Duration(minutes: 110 + index),
        screenOnDuration: Duration(minutes: 90 + index),
        outdoorDuration: Duration(minutes: 20),
        postureRiskCount: 1,
        highNoiseExposureDuration: Duration.zero,
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith(
            (Ref ref) async => _buildViewModel(),
          ),
          metricsRepositoryProvider.overrideWithValue(
            InMemoryMetricsRepository(metrics: metrics),
          ),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('步数'));
    await tester.pumpAndSettle();

    final expectedCompletion = ((3200 + 6 * 500) / 6000 * 100).round();
    expect(find.text('步数详情'), findsOneWidget);
    expect(find.text('过去 7 天柱状图'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(
      find.textContaining('完成率 $expectedCompletion%'),
      findsOneWidget,
    );
  });

  testWidgets('久坐卡片弹层展示时间轴', (WidgetTester tester) async {
    final now = DateTime.now();
    final baseDay = DateTime(now.year, now.month, now.day);
    final activityRepository = InMemoryActivityRepository(
      samples: <ActivitySample>[
        ActivitySample(
          capturedAt: baseDay.add(const Duration(hours: 9)),
          duration: const Duration(minutes: 45),
          type: ActivityType.stationary,
          confidence: 0.95,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
        ActivitySample(
          capturedAt: baseDay.add(const Duration(hours: 12)),
          duration: const Duration(minutes: 50),
          type: ActivityType.stationary,
          confidence: 0.96,
          stepCount: 0,
          source: MotionSampleSource.sensorFusion,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith(
            (Ref ref) async => _buildViewModel(),
          ),
          activityRepositoryProvider.overrideWithValue(activityRepository),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('久坐'));
    await tester.pumpAndSettle();

    expect(find.text('久坐详情'), findsOneWidget);
    expect(find.text('今日久坐时段时间轴'), findsOneWidget);
    expect(find.text('连续久坐 45 分钟'), findsOneWidget);
    expect(find.text('连续久坐 50 分钟'), findsOneWidget);
  });

  testWidgets('屏幕卡片弹层展示分时段使用分布', (WidgetTester tester) async {
    final now = DateTime.now();
    final baseDay = DateTime(now.year, now.month, now.day);
    final usageRepository = InMemoryUsageSummaryRepository(
      summaries: <DigitalUsageSummary>[
        DigitalUsageSummary(
          date: baseDay.subtract(const Duration(days: 1)),
          screenOnDuration: const Duration(hours: 2),
          unlockCount: 6,
          nighttimeUsageDuration: const Duration(minutes: 30),
          focusSessionBreakCount: 2,
          topCategory: UsageCategory.productivity,
          viewCount: 8,
          longestContinuousUsageDuration: const Duration(minutes: 35),
          source: DigitalUsageSource.lifecycleAlternative,
          completeness: UsageDataCompleteness.full,
        ),
        DigitalUsageSummary(
          date: baseDay,
          screenOnDuration: const Duration(hours: 2, minutes: 30),
          unlockCount: 8,
          nighttimeUsageDuration: const Duration(minutes: 45),
          focusSessionBreakCount: 3,
          topCategory: UsageCategory.productivity,
          viewCount: 12,
          longestContinuousUsageDuration: const Duration(minutes: 40),
          source: DigitalUsageSource.lifecycleAlternative,
          completeness: UsageDataCompleteness.full,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          overviewViewModelProvider.overrideWith(
            (Ref ref) async => _buildViewModel(),
          ),
          usageSummaryRepositoryProvider.overrideWithValue(usageRepository),
        ],
        child: const MaterialApp(home: OverviewPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('看屏'));
    await tester.pumpAndSettle();

    expect(find.text('屏幕详情'), findsOneWidget);
    expect(find.text('分时段使用分布'), findsOneWidget);
    expect(find.text('白天'), findsOneWidget);
    expect(find.text('夜间'), findsOneWidget);
    expect(find.text('与昨日 ↑ 30 分钟'), findsOneWidget);
  });
}

OverviewViewModel _buildViewModel() {
  return const OverviewViewModel(
    screenState: OverviewScreenState.ready,
    isLoading: false,
    verdicts: <RuleVerdict>[],
    summaryLabel: '状态稳定',
    summaryDetail: '今天整体还不错。',
    todayStatusLabel: '状态稳定',
    todayStatusDetail: '今天整体还不错。',
    conclusionLabel: '状态稳定',
    conclusionDetail: '今天整体还不错。',
    metrics: OverviewMetricSnapshot(
      stepCount: 6200,
      sedentaryMinutes: 145,
      screenMinutes: 150,
      outdoorMinutes: 20,
    ),
    reminders: <ReminderRecord>[],
    permissionStatuses: <PermissionType, PermissionGrantStatus>{},
    missingDimensions: <String>[],
    hasRealData: true,
  );
}
