import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/domain/reminder/reminder_record.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/rules/engine/rule_verdict.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/permission_status_service.dart';
import 'package:health_monitor/storage/repositories/query_window.dart';

enum BriefingTimeRange {
  today,
  yesterday,
  recent7Days,
}

extension BriefingTimeRangeLabel on BriefingTimeRange {
  String get label {
    switch (this) {
      case BriefingTimeRange.today:
        return '今日';
      case BriefingTimeRange.yesterday:
        return '昨日';
      case BriefingTimeRange.recent7Days:
        return '最近 7 天';
    }
  }
}

class BriefingViewModel {
  const BriefingViewModel({
    required this.selectedRange,
    required this.windowLabel,
    required this.screenState,
    required this.verdicts,
    required this.summaryLabel,
    required this.summaryDetail,
    required this.metrics,
    required this.reminders,
    required this.permissionStatuses,
    required this.hasRealData,
    required this.isLoading,
    this.missingDimensions = const <String>[],
  });

  final BriefingTimeRange selectedRange;
  final String windowLabel;
  final OverviewScreenState screenState;
  final List<RuleVerdict> verdicts;
  final String summaryLabel;
  final String summaryDetail;
  final OverviewMetricSnapshot metrics;
  final List<ReminderRecord> reminders;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final bool hasRealData;
  final bool isLoading;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;

  List<RuleVerdict> get secondaryVerdicts {
    if (verdicts.length <= 1) {
      return const <RuleVerdict>[];
    }
    return verdicts.skip(1).toList(growable: false);
  }
}

final briefingTimeRangeProvider = StateProvider<BriefingTimeRange>((Ref ref) {
  return BriefingTimeRange.today;
});

final briefingViewModelProvider = FutureProvider<BriefingViewModel>((Ref ref) async {
  ref.watch(dataCollectorRevisionProvider);
  ref.watch(dataCollectorProvider);
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final now = DateTime.now();
  final snapshot = await insightService.buildSnapshot(
    window: _windowForRange(selectedRange, referenceTime: now),
    referenceTime: now,
  );
  final primary = snapshot.verdicts.isEmpty ? null : snapshot.verdicts.first;

  return BriefingViewModel(
    selectedRange: selectedRange,
    windowLabel: _windowLabelForRange(selectedRange),
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: snapshot.hasRealData,
      hasReminderHistory: snapshot.reminderHistory.isNotEmpty,
    ),
    verdicts: snapshot.verdicts,
    summaryLabel: primary?.summary ?? '等待采集数据',
    summaryDetail: primary?.detail ?? '应用刚启动，数据还在积累，稍后再回来查看简报。',
    metrics: OverviewMetricSnapshot(
      stepCount: snapshot.metrics.stepCount,
      sedentaryMinutes: snapshot.metrics.sedentaryMinutes,
      screenMinutes: snapshot.metrics.screenMinutes,
      outdoorMinutes: snapshot.metrics.outdoorMinutes,
    ),
    reminders: snapshot.reminderHistory,
    permissionStatuses: permissionStatuses,
    missingDimensions: snapshot.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
    hasRealData: snapshot.hasRealData,
    isLoading: false,
  );
});

String _windowLabelForRange(BriefingTimeRange range) {
  switch (range) {
    case BriefingTimeRange.today:
      return '今日';
    case BriefingTimeRange.yesterday:
      return '昨日';
    case BriefingTimeRange.recent7Days:
      return '最近 7 天';
  }
}

QueryWindow _windowForRange(
  BriefingTimeRange range, {
  required DateTime referenceTime,
}) {
  switch (range) {
    case BriefingTimeRange.today:
      return QueryWindow.calendarDay(referenceDate: referenceTime);
    case BriefingTimeRange.yesterday:
      return QueryWindow.calendarDay(
        referenceDate: referenceTime.subtract(const Duration(days: 1)),
      );
    case BriefingTimeRange.recent7Days:
      return QueryWindow.recentCalendarDays(
        7,
        referenceDate: referenceTime,
      );
  }
}
