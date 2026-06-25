import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_builder.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/features/overview/providers/daily_rhythm_clock_provider.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

final dailyRhythmUiModelProvider = Provider<DailyRhythmUiModel?>((Ref ref) {
  final readyData = ref.watch(overviewReadyDataStateProvider);
  if (readyData == null) {
    return null;
  }

  // 每小时触发重建；窗口右边界不早于仪表盘快照时刻，避免节点被裁到轴外。
  final tickNow = ref.watch(dailyRhythmClockProvider);
  final generatedAt = readyData.dashboard.generatedAt;
  final now = tickNow.isAfter(generatedAt) ? tickNow : generatedAt;
  return buildDailyRhythmUiModel(
    dashboard: readyData.dashboard,
    missingDimensions: readyData.missingDimensions,
    calendarDay: DateTime(now.year, now.month, now.day),
    windowEnd: now,
  );
});
