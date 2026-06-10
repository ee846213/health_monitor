import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/rules/engine/activity_rules.dart';
import 'package:health_monitor/rules/engine/environment_rules.dart';
import 'package:health_monitor/rules/engine/posture_rules.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/rules/engine/usage_rules.dart';
import 'package:health_monitor/rules/input/rule_input.dart';
import 'package:health_monitor/rules/input/rule_input_service.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/permission_status_service.dart';
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
    this.missingDimensions = const <String>[],
    this.hasRealData = false,
    this.isLoading = false,
  });

  final OverviewScreenState screenState;
  final bool isLoading;
  final List<RuleVerdict> verdicts;
  final String summaryLabel;
  final String summaryDetail;
  final OverviewMetricSnapshot metrics;
  final List<ReminderRecord> reminders;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final bool hasRealData;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;

  List<RuleVerdict> get secondaryVerdicts {
    if (verdicts.length <= 1) {
      return const <RuleVerdict>[];
    }
    return verdicts.skip(1).toList(growable: false);
  }
}

final overviewViewModelProvider =
    FutureProvider<OverviewViewModel>((Ref ref) async {
  // 数据版本号是一个轻量刷新信号，写入本地样本后会递增。
  // 首页、简报和提醒页都订阅它，这样真实数据变化后就会重新计算。
  ref.watch(dataCollectorRevisionProvider);
  // 首页、简报和提醒都依赖同一批采集结果。
  // 这里主动 watch 采集器，确保这些页面消费的是同一份实时状态，
  // 避免每个页面各自启动独立采集导致规则结果和提醒历史不一致。
  ref.watch(dataCollectorProvider);

  final activityRepository = ref.watch(sharedActivityRepo);
  final locationRepository = ref.watch(sharedLocationRepo);
  final noiseRepository = ref.watch(sharedNoiseRepo);
  final usageRepository = ref.watch(sharedUsageRepo);
  final metricsRepository = ref.watch(sharedMetricsRepo);
  final reminderRepository = await ref.watch(reminderRepositoryProvider.future);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);

  final now = DateTime.now();
  final window = QueryWindow.recentDay(referenceTime: now);
  final inputService = RuleInputService(
    activityRepository: activityRepository,
    locationRepository: locationRepository,
    noiseRepository: noiseRepository,
    usageRepository: usageRepository,
    metricsRepository: metricsRepository,
  );
  final input = await inputService.buildInput(window: window);

  const rules = <HealthRule>[
    ActivityRule(),
    PostureRule(),
    UsageRule(),
    EnvironmentRule(),
  ];
  final verdicts = <RuleVerdict>[];
  for (final rule in rules) {
    verdicts.addAll(rule.evaluate(input));
  }
  verdicts.sort(_compareVerdictPriority);

  final generatedReminders = _buildReminderRecords(verdicts, now);
  await reminderRepository.saveAll(generatedReminders);
  final historyReminders = await reminderRepository.listRecentDays(
    7,
    referenceDate: now,
  );

  final primary = verdicts.isEmpty ? null : verdicts.first;
  final hasRealData = input.isDimensionAvailable('activity') ||
      input.isDimensionAvailable('location') ||
      input.isDimensionAvailable('noise') ||
      input.isDimensionAvailable('digital_usage') ||
      input.isDimensionAvailable('daily_metrics');

  return OverviewViewModel(
    screenState: _resolveScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: hasRealData,
    ),
    isLoading: false,
    verdicts: verdicts,
    summaryLabel: primary?.summary ?? '等待采集数据',
    summaryDetail: primary?.detail ?? '应用刚启动，数据还在积累，稍后再回来查看今天的健康概览。',
    metrics: OverviewMetricSnapshot(
      stepCount: input.totalSteps,
      sedentaryMinutes: _estimateSedentaryMinutes(input),
      screenMinutes: input.totalScreenMinutes.round(),
      outdoorMinutes: input.totalOutdoorMinutes.round(),
    ),
    reminders: historyReminders,
    permissionStatuses: permissionStatuses,
    missingDimensions: input.missingDimensions,
    hasRealData: hasRealData,
  );
});

final reminderListProvider = FutureProvider<List<ReminderRecord>>((Ref ref) async {
  // 提醒记录页读取的是持久化历史，而不是本轮规则刚算出的临时列表。
  // 这样用户从详情页返回、重进页面或重启应用后，看到的仍然是同一份历史记录。
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);
  await ref.watch(overviewViewModelProvider.future);
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

int _compareVerdictPriority(RuleVerdict left, RuleVerdict right) {
  const priority = <String, int>{
    'concern': 0,
    'warning': 1,
    'normal': 2,
  };
  return (priority[left.level] ?? 9).compareTo(priority[right.level] ?? 9);
}

OverviewScreenState _resolveScreenState({
  required Map<PermissionType, PermissionGrantStatus> permissionStatuses,
  required bool hasRealData,
}) {
  final motionStatus = permissionStatuses[PermissionType.motion];
  final locationStatus = permissionStatuses[PermissionType.location];
  final microphoneStatus = permissionStatuses[PermissionType.microphone];
  final corePermissionsDenied = <PermissionGrantStatus?>[
    motionStatus,
    locationStatus,
    microphoneStatus,
  ].every(_isUnavailablePermission);

  if (corePermissionsDenied) {
    return OverviewScreenState.permissionDenied;
  }
  if (!hasRealData) {
    return OverviewScreenState.dataInsufficient;
  }
  return OverviewScreenState.ready;
}

bool _isUnavailablePermission(PermissionGrantStatus? status) {
  return status == PermissionGrantStatus.denied ||
      status == PermissionGrantStatus.restricted;
}

List<ReminderRecord> _buildReminderRecords(
  List<RuleVerdict> verdicts,
  DateTime referenceTime,
) {
  final reminderVerdicts = verdicts
      .where((RuleVerdict verdict) => verdict.shouldRemind)
      .toList(growable: false);

  return List<ReminderRecord>.generate(
    reminderVerdicts.length,
    (int index) => ReminderRecord.fromVerdict(
      verdict: reminderVerdicts[index],
      // 当前规则层还没有独立的提醒事件时间戳，因此这里按固定间隔回推时间。
      // 这样既能保证同一轮结果的展示顺序稳定，也能在后续接入原生后台提醒事件时
      // 不必再改页面消费契约，只替换这里的触发时间来源即可。
      now: referenceTime.subtract(Duration(minutes: index * 5)),
    ),
    growable: false,
  );
}

int _estimateSedentaryMinutes(RuleInput input) {
  if (input.totalSedentaryMinutes > 0) {
    return input.totalSedentaryMinutes.round();
  }
  final stationaryMinutes = input.activitySamples
      .where((sample) => sample.type.name == 'stationary')
      .fold<int>(
        0,
        (int total, sample) => total + sample.duration.inMinutes,
      );
  return stationaryMinutes;
}
