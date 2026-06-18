import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/briefing/daily_brief_snapshot.dart';
import 'package:health_monitor/domain/environment/environment_overview.dart';
import 'package:health_monitor/domain/permission/permission_descriptor.dart';
import 'package:health_monitor/features/overview/providers/overview_providers.dart';
import 'package:health_monitor/services/data_collector.dart';
import 'package:health_monitor/services/health_insight_service.dart';
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
    required this.briefSnapshot,
    required this.permissionStatuses,
    required this.hasRealData,
    required this.isLoading,
    this.missingDimensions = const <String>[],
  });

  final BriefingTimeRange selectedRange;
  final String windowLabel;
  final OverviewScreenState screenState;
  final DailyBriefSnapshot briefSnapshot;
  final Map<PermissionType, PermissionGrantStatus> permissionStatuses;
  final List<String> missingDimensions;
  final bool hasRealData;
  final bool isLoading;

  bool get hasMissingDimensions => missingDimensions.isNotEmpty;
}

final briefingReferenceTimeProvider = Provider<DateTime Function()>((Ref ref) {
  return DateTime.now;
});

final briefingTimeRangeProvider = StateProvider<BriefingTimeRange>((Ref ref) {
  return BriefingTimeRange.today;
});

final briefingRangeRevisionProvider = Provider<String>((Ref ref) {
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final referenceTime = ref.watch(briefingReferenceTimeProvider)();
  final dayKeys = _dayKeysForRange(selectedRange, referenceTime);

  return ref.watch(
    dataCollectorDailyRevisionProvider.select(
      (Map<String, int> revisions) =>
          dayKeys.map((String dayKey) => '${revisions[dayKey] ?? 0}').join('|'),
    ),
  );
});

final briefingViewModelProvider =
    FutureProvider<BriefingViewModel>((Ref ref) async {
  ref.watch(briefingRangeRevisionProvider);
  ref.watch(dataCollectorProvider);
  final selectedRange = ref.watch(briefingTimeRangeProvider);
  final permissionStatuses = await ref.watch(permissionStatusProvider.future);
  final insightService = ref.watch(healthInsightServiceProvider);
  final now = ref.watch(briefingReferenceTimeProvider)();
  final snapshot = await insightService.buildSnapshot(
    window: _windowForRange(selectedRange, referenceTime: now),
    referenceTime: now,
  );

  return BriefingViewModel(
    selectedRange: selectedRange,
    windowLabel: _windowLabelForRange(selectedRange),
    screenState: resolveOverviewScreenState(
      permissionStatuses: permissionStatuses,
      hasRealData: snapshot.hasRealData,
      hasReminderHistory: snapshot.reminderHistory.isNotEmpty,
    ),
    briefSnapshot: _buildDailyBriefSnapshot(snapshot),
    permissionStatuses: permissionStatuses,
    missingDimensions: snapshot.input.missingDimensions
        .map(localizedDimensionLabel)
        .toList(growable: false),
    hasRealData: snapshot.hasRealData,
    isLoading: false,
  );
});

String _windowLabelForRange(BriefingTimeRange range) {
  return range.label;
}

DailyBriefSnapshot _buildDailyBriefSnapshot(HealthInsightSnapshot snapshot) {
  final usageSummary = snapshot.screenUsageHabitSummary;
  final primaryVerdict =
      snapshot.verdicts.isEmpty ? null : snapshot.verdicts.first;
  final headline =
      usageSummary?.headline ?? primaryVerdict?.summary ?? '等待采集数据';
  final supportingDetail = usageSummary?.supportingDetail ??
      primaryVerdict?.detail ??
      '应用刚启动，数据还在积累，稍后再回来查看简报。';

  final suggestions = _buildSuggestions(snapshot);
  final metrics = <DailyBriefMetric>[
    DailyBriefMetric(
      label: '步数',
      value: '${snapshot.metrics.stepCount}',
      unit: '步',
    ),
    DailyBriefMetric(
      label: '久坐',
      value: '${snapshot.metrics.sedentaryMinutes}',
      unit: '分钟',
    ),
    DailyBriefMetric(
      label: '屏幕使用',
      value: '${snapshot.metrics.screenMinutes}',
      unit: '分钟',
    ),
  ];

  final qualityNote = usageSummary?.qualityNote ??
      (snapshot.input.missingDimensions.isNotEmpty
          ? '部分维度仍在积累：'
              '${snapshot.input.missingDimensions.map(localizedDimensionLabel).join('、')}。'
          : null);

  return DailyBriefSnapshot(
    headline: headline,
    supportingDetail: supportingDetail,
    metrics: metrics,
    suggestions: suggestions,
    qualityNote: qualityNote,
  );
}

List<String> _buildSuggestions(HealthInsightSnapshot snapshot) {
  final suggestions = <String>[];
  final metrics = snapshot.metrics;
  final usageSummary = snapshot.screenUsageHabitSummary;

  if (usageSummary != null && usageSummary.headline.contains('深夜')) {
    suggestions.add('今晚尽量提前结束看屏，把最后十分钟留给放松和入睡准备。');
  } else if (usageSummary != null && usageSummary.headline.contains('查看频率偏高')) {
    suggestions.add('把零散查看压缩到固定时段，给连续专注留出完整区间。');
  } else if (usageSummary != null && usageSummary.headline.contains('时段激活过密')) {
    suggestions.add('遇到短间隔再次拿起手机时，先停一秒确认是否真的需要查看。');
  }

  final environmentOverview = snapshot.environmentOverview;
  if (environmentOverview != null &&
      environmentOverview.primaryConcern ==
          EnvironmentPrimaryConcern.highNoise) {
    suggestions.add('夜间环境偏嘈杂，睡前尽量切到更安静的空间。');
  } else if (environmentOverview != null &&
      environmentOverview.primaryConcern ==
          EnvironmentPrimaryConcern.lowLight) {
    suggestions.add('白天光线偏暗，工作或学习时尽量靠近自然光。');
  }

  if (metrics.stepCount < 5000) {
    suggestions.add('今天活动量偏少，可以安排一次 10 到 15 分钟的补步。');
  } else if (metrics.sedentaryMinutes >= 180) {
    suggestions.add('久坐时间偏长，接下来每小时起身活动两三分钟会更稳妥。');
  }

  if (suggestions.isEmpty) {
    suggestions.add('整体节奏比较平稳，继续保持现在的作息和用机边界。');
  }

  return suggestions.take(2).toList(growable: false);
}

QueryWindow _windowForRange(
  BriefingTimeRange range, {
  required DateTime referenceTime,
}) {
  final anchorDate = _anchorDateForRange(range, referenceTime);
  switch (range) {
    case BriefingTimeRange.today:
      return QueryWindow.calendarDay(referenceDate: anchorDate);
    case BriefingTimeRange.yesterday:
      return QueryWindow.calendarDay(referenceDate: anchorDate);
    case BriefingTimeRange.recent7Days:
      // 最近 7 日简报只回顾已完成自然日，避免今日实时采集持续拉动页面刷新。
      return QueryWindow.recentCalendarDays(
        7,
        referenceDate: anchorDate,
      );
  }
}

DateTime _anchorDateForRange(
  BriefingTimeRange range,
  DateTime referenceTime,
) {
  switch (range) {
    case BriefingTimeRange.today:
      return referenceTime;
    case BriefingTimeRange.yesterday:
    case BriefingTimeRange.recent7Days:
      return referenceTime.subtract(const Duration(days: 1));
  }
}

List<String> _dayKeysForRange(
  BriefingTimeRange range,
  DateTime referenceTime,
) {
  final window = _windowForRange(range, referenceTime: referenceTime);
  return window.dailyDates().map(_dayKey).toList(growable: false);
}

String _dayKey(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}
