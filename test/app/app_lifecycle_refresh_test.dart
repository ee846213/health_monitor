import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_monitor/app/app.dart';
import 'package:health_monitor/app/background_capture_bootstrap.dart';
import 'package:health_monitor/domain/background/android_background_capture_host_status.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/scoring/health_score_calculator.dart';
import 'package:health_monitor/domain/trends/trend_snapshot.dart';
import 'package:health_monitor/features/briefing/providers/briefing_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';
import 'package:health_monitor/features/trends/providers/trend_analysis_provider.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/digital_usage_capture_service.dart';
import 'package:health_monitor/services/location_capture_service.dart';
import 'package:health_monitor/services/motion_capture_service.dart';
import 'package:health_monitor/services/noise_capture_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';

void main() {
  testWidgets('应用从后台恢复后应在同步完成后刷新首页数据', (WidgetTester tester) async {
    final collector = _LifecycleRefreshTestCollector();
    final container = ProviderContainer(
      overrides: <Override>[
        dataCollectorProvider.overrideWithValue(collector),
        androidBackgroundCaptureBootstrapServiceProvider.overrideWithValue(
          AndroidBackgroundCaptureBootstrapService(
            startBackgroundCapture: (_) async {},
            getHostStatus: () async => const AndroidBackgroundCaptureHostStatus(
              isRunning: false,
              summary: 'test',
            ),
            isAndroid: () => false,
          ),
        ),
        overviewReadyDataProvider.overrideWith(
          (Ref ref) async => _buildOverviewReadyData(collector.currentScore),
        ),
        overviewViewModelProvider.overrideWith(
          (Ref ref) async => _buildOverviewViewModel(collector.currentScore),
        ),
        briefingViewModelProvider.overrideWith(
          (Ref ref) async => _buildBriefingViewModel(collector.currentScore),
        ),
        trendAnalysisViewModelProvider.overrideWith(
          (Ref ref) async => _buildTrendSnapshot(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const HealthMonitorApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(
      container
          .read(overviewReadyDataStateProvider)
          ?.dashboard
          .healthScore
          .totalScore,
      10,
    );

    collector.scheduleNextScore(99);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(
      container
          .read(overviewReadyDataStateProvider)
          ?.dashboard
          .healthScore
          .totalScore,
      99,
    );
    expect(collector.resumeForegroundCaptureCount, 1);
    expect(collector.pauseForegroundCaptureCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
  });
}

class _LifecycleRefreshTestCollector extends DataCollector {
  _LifecycleRefreshTestCollector()
      : super(
          activityRepository: SharedActivityRepository(),
          noiseRepository: SharedNoiseRepository(),
          locationRepository: SharedLocationRepository(),
          usageRepository: SharedUsageRepository(),
          metricsRepository: SharedMetricsRepository(),
          motionCaptureService: MotionCaptureService(
            sensorStreamFactory: ({
              Duration samplingPeriod = const Duration(milliseconds: 200),
            }) =>
                const Stream<MotionVectorSample>.empty(),
          ),
          noiseCaptureService: NoiseCaptureService(
            noiseStreamFactory: () => const Stream<NoiseReadingSample>.empty(),
          ),
          locationCaptureService: LocationCaptureService(
            positionStreamFactory: ({
              Duration samplingPeriod = const Duration(seconds: 30),
            }) =>
                const Stream<GeoPositionSample>.empty(),
            isLocationServiceEnabled: () async => true,
            checkPermission: () async => GeoPermissionStatus.allowed,
            requestPermission: () async => GeoPermissionStatus.allowed,
          ),
          digitalUsageCaptureService: DigitalUsageCaptureService(
            lifecycleEventStreamFactory: () =>
                const Stream<AppUsageEvent>.empty(),
          ),
          syncNativeRiskEvents: () async => 0,
        );

  int currentScore = 10;
  int? _nextScore;
  int resumeForegroundCaptureCount = 0;
  int pauseForegroundCaptureCount = 0;

  void scheduleNextScore(int score) {
    _nextScore = score;
  }

  @override
  void resumeForegroundCapture() {
    resumeForegroundCaptureCount += 1;
  }

  @override
  Future<void> pauseForegroundCapture() async {
    pauseForegroundCaptureCount += 1;
  }

  @override
  Future<void> syncNativeStepCount({DateTime? referenceTime}) async {
    final nextScore = _nextScore;
    if (nextScore == null) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
    currentScore = nextScore;
    _nextScore = null;
  }

  @override
  Future<void> syncUsageSummary({DateTime? referenceTime}) async {}

  @override
  Future<void> syncNativeRiskEvents() async {}
}

OverviewReadyData _buildOverviewReadyData(int score) {
  final viewModel = _buildOverviewViewModel(score);
  return OverviewReadyData(
    dashboard: viewModel.dashboard,
    permissionStatuses: viewModel.permissionStatuses,
    missingDimensions: viewModel.missingDimensions,
    reminders: viewModel.reminders,
    preciseDetectionNotice: viewModel.preciseDetectionNotice,
  );
}

OverviewDashboardViewModel _buildOverviewViewModel(int score) {
  return OverviewDashboardViewModel(
    screenState: OverviewScreenState.ready,
    dashboard: DashboardSnapshot(
      generatedAt: DateTime(2026, 7, 5, 9),
      healthScore: HealthScoreBreakdown(
        stepScore: score,
        sedentaryScore: score,
        screenScore: score,
        totalScore: score,
      ),
      stepCard: DashboardStepCard(
        currentSteps: 3200,
        goalSteps: 6000,
        achievementPercent: 53,
      ),
      sedentaryCard: const DashboardSedentaryCard(
        totalMinutes: 80,
        longestSingleMinutes: 32,
      ),
      screenCard: const DashboardScreenCard(
        totalMinutes: 95,
        yesterdayDeltaMinutes: -10,
        changeDirection: DashboardChangeDirection.down,
      ),
      environmentSnapshot: const DashboardEnvironmentSnapshot(
        lightLabel: '舒适',
        noiseLabel: '正常',
      ),
      dailyAdviceBubble: const DailyAdviceBubble(
        text: '测试建议',
        source: DailyAdviceSource.fallback,
      ),
      hasRealData: true,
      hasReminderHistory: false,
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
  );
}

BriefingViewModel _buildBriefingViewModel(int score) {
  return BriefingViewModel(
    selectionKey: 'day:2026-07-05',
    selectedRange: BriefingTimeRange.today,
    windowLabel: '今日',
    screenState: OverviewScreenState.ready,
    briefSnapshot: DailyBriefSnapshot(
      headline: 'headline',
      supportingDetail: 'detail',
      metrics: <DailyBriefMetric>[
        DailyBriefMetric(label: '步数', value: '$score', unit: '步'),
      ],
      suggestions: const <String>['suggestion'],
    ),
    permissionStatuses: const <PermissionType, PermissionGrantStatus>{},
    hasRealData: true,
    isLoading: false,
  );
}

TrendSnapshot _buildTrendSnapshot() {
  return TrendSnapshot(
    generatedAt: DateTime(2026, 7, 5, 9),
    selectedTab: TrendTab.steps,
    title: '最近 7 天步数',
    unitLabel: '步',
    points: <TrendPoint>[
      TrendPoint(label: 'Mon', value: 3000),
      TrendPoint(label: 'Tue', value: 3200),
    ],
    insightText: '保持稳定',
  );
}
