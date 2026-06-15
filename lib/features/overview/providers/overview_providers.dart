import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/android_risk_event_bridge.dart';
import 'package:health_monitor/services/android_usage_stats_bridge.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/health_insight_service.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/services/platform_bridge_service.dart';
import 'package:health_monitor/storage/isar/app_isar.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';
import 'package:health_monitor/storage/repositories/reminder_repository.dart';

final overviewPermissionStatusServiceProvider =
    Provider<PermissionStatusService>((Ref ref) {
  return const PermissionHandlerStatusService();
});

final permissionStatusProvider =
    FutureProvider<Map<PermissionType, PermissionGrantStatus>>((Ref ref) async {
  final service = ref.watch(overviewPermissionStatusServiceProvider);
  return service.getStatuses();
});

final reminderRepositoryProvider = FutureProvider<ReminderRepository>(
  (Ref ref) async {
    final isar = await ref.watch(appIsarProvider.future);
    return IsarReminderRepository(isar);
  },
);

final healthInsightServiceProvider = Provider<HealthInsightService>((Ref ref) {
  return HealthInsightService(
    activityRepository: ref.watch(sharedActivityRepo),
    ambientLightRepository: ref.watch(sharedAmbientLightRepo),
    locationRepository: ref.watch(sharedLocationRepo),
    noiseRepository: ref.watch(sharedNoiseRepo),
    usageRepository: ref.watch(sharedUsageRepo),
    metricsRepository: ref.watch(sharedMetricsRepo),
    reminderRepositoryLoader: () => ref.read(reminderRepositoryProvider.future),
    androidRiskEventBridge: AndroidRiskEventBridge(
      platformBridgeService: PlatformBridgeService(),
    ),
    androidUsageStatsBridge: AndroidUsageStatsBridge(
      platformBridgeService: PlatformBridgeService(),
    ),
  );
});

enum OverviewScreenState {
  ready,
  permissionDenied,
  dataInsufficient,
}

class OverviewMetricSnapshot {
  const OverviewMetricSnapshot({
    required this.stepCount,
    required this.sedentaryMinutes,
    required this.screenMinutes,
    required this.outdoorMinutes,
  });

  final int stepCount;
  final int sedentaryMinutes;
  final int screenMinutes;
  final int outdoorMinutes;
}

class OverviewViewModel {
  const OverviewViewModel({
    required this.screenState,
    required this.verdicts,
    required this.summaryLabel,
    required this.summaryDetail,
    required this.metrics,
    required this.reminders,
    required this.permissionStatuses,
    this.todayStatusLabel,
    this.todayStatusDetail,
    this.conclusionLabel,
    this.conclusionDetail,
    this.preciseDetectionNotice,
    this.missingDimensions = const <String>[],
    this.hasRealData = false,
    this.isLoading = false,
  });

  final OverviewScreenState screenState;
  final bool isLoading;
  final List<RuleVerdict> verdicts;
  final String summaryLabel;
  final String summaryDetail;
  final String? todayStatusLabel;
  final String? todayStatusDetail;
  final String? conclusionLabel;
  final String? conclusionDetail;
  final String? preciseDetectionNotice;
  final OverviewMetricSnapshot metrics;
  final List<ReminderRecord> reminders;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final bool hasRealData;

  String get resolvedTodayStatusLabel => todayStatusLabel ?? summaryLabel;
  String get resolvedTodayStatusDetail => todayStatusDetail ?? summaryDetail;
  String get resolvedConclusionLabel => conclusionLabel ?? summaryLabel;
  String get resolvedConclusionDetail => conclusionDetail ?? summaryDetail;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;
  bool get hasPreciseDetectionNotice =>
      preciseDetectionNotice != null && preciseDetectionNotice!.isNotEmpty;

  List<RuleVerdict> get secondaryVerdicts {
    if (verdicts.length <= 1) {
      return const <RuleVerdict>[];
    }
    return verdicts.skip(1).toList(growable: false);
  }
}

final walkingScreenRiskNoticeProvider =
    FutureProvider<String?>((Ref ref) async {
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  return buildWalkingScreenRiskPrecisionNotice(
    permissionStatuses: permissionStatuses,
    isAndroid: Platform.isAndroid,
    isIOS: Platform.isIOS,
  );
});

final overviewViewModelProvider =
    FutureProvider<OverviewViewModel>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);

  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final snapshot = await insightService.buildSnapshot(
    window: QueryWindow.recentDay(referenceTime: DateTime.now()),
  );

  final metrics = OverviewMetricSnapshot(
    stepCount: snapshot.metrics.stepCount,
    sedentaryMinutes: snapshot.metrics.sedentaryMinutes,
    screenMinutes: snapshot.metrics.screenMinutes,
    outdoorMinutes: snapshot.metrics.outdoorMinutes,
  );
  final primary = snapshot.verdicts.isEmpty ? null : snapshot.verdicts.first;
  final todayStatusLabel = _buildTodayStatusLabel(
    metrics: metrics,
    hasRealData: snapshot.hasRealData,
  );
  final todayStatusDetail = _buildTodayStatusDetail(
    metrics: metrics,
    hasRealData: snapshot.hasRealData,
  );

  return OverviewViewModel(
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: snapshot.hasRealData,
      hasReminderHistory: snapshot.reminderHistory.isNotEmpty,
    ),
    isLoading: false,
    verdicts: snapshot.verdicts,
    summaryLabel: todayStatusLabel,
    summaryDetail: todayStatusDetail,
    todayStatusLabel: todayStatusLabel,
    todayStatusDetail: todayStatusDetail,
    conclusionLabel: primary?.summary ?? '暂时没风险',
    conclusionDetail: primary?.detail ?? '当前没有需要优先处理的事项。',
    preciseDetectionNotice: buildWalkingScreenRiskPrecisionNotice(
      permissionStatuses: permissionStatuses,
      isAndroid: Platform.isAndroid,
      isIOS: Platform.isIOS,
    ),
    metrics: metrics,
    reminders: snapshot.reminderHistory,
    permissionStatuses: permissionStatuses,
    missingDimensions: snapshot.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
    hasRealData: snapshot.hasRealData,
  );
});

final reminderListProvider =
    FutureProvider<List<ReminderRecord>>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);
  final repository = await ref.watch(reminderRepositoryProvider.future);
  return repository.listRecentDays(
    7,
    referenceDate: DateTime.now(),
  );
});

final latestReminderProvider = FutureProvider<ReminderRecord?>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  final repository = await ref.watch(reminderRepositoryProvider.future);
  return repository.getLatest();
});

OverviewScreenState resolveOverviewScreenState({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  required bool hasRealData,
  required bool hasReminderHistory,
}) {
  final motionStatus = permissionStatuses[PermissionType.motion];
  final locationStatus = permissionStatuses[PermissionType.location];
  final microphoneStatus = permissionStatuses[PermissionType.microphone];
  final corePermissionsDenied = <PermissionGrantStatus?>[
    motionStatus,
    locationStatus,
    microphoneStatus,
  ].every(_isUnavailablePermission);

  if (corePermissionsDenied && !hasRealData && !hasReminderHistory) {
    return OverviewScreenState.permissionDenied;
  }
  if (!hasRealData && !hasReminderHistory) {
    return OverviewScreenState.dataInsufficient;
  }
  return OverviewScreenState.ready;
}

bool _isUnavailablePermission(PermissionGrantStatus? status) {
  return status == PermissionGrantStatus.denied ||
      status == PermissionGrantStatus.restricted;
}

String localizedDimensionLabel(String dimension) {
  switch (dimension) {
    case 'activity':
      return '活动状态';
    case 'location':
      return '位置摘要';
    case 'noise':
      return '环境噪音';
    case 'light':
      return '环境光照';
    case 'digital_usage':
      return '数字生活';
    case 'daily_metrics':
      return '日指标聚合';
    default:
      return dimension;
  }
}

String? buildWalkingScreenRiskPrecisionNotice({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  required bool isAndroid,
  required bool isIOS,
}) {
  if (isIOS) {
    return '当前平台仅提供替代指标，不提供走路看屏精确事件识别。';
  }
  if (!isAndroid) {
    return null;
  }

  final backgroundStatus =
      permissionStatuses[PermissionType.backgroundCapture] ??
          PermissionGrantStatus.unknown;
  if (backgroundStatus != PermissionGrantStatus.granted) {
    return '移动中看屏风险仅在后台采集开启后可精确识别。';
  }
  return null;
}

String _buildTodayStatusLabel({
  required OverviewMetricSnapshot metrics,
  required bool hasRealData,
}) {
  if (!hasRealData) {
    return '数据还在积累';
  }
  if (metrics.stepCount < 5000) {
    return '活动偏少';
  }
  if (metrics.sedentaryMinutes >= 180) {
    return '久坐偏长';
  }
  if (metrics.screenMinutes >= 240) {
    return '看屏偏多';
  }
  return '状态平稳';
}

String _buildTodayStatusDetail({
  required OverviewMetricSnapshot metrics,
  required bool hasRealData,
}) {
  if (!hasRealData) {
    return '数据还在积累，稍后再看。';
  }
  return '步数 ${metrics.stepCount}，久坐 ${metrics.sedentaryMinutes} 分钟。';
}
