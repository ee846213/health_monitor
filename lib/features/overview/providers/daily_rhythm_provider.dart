import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/features/overview/providers/overview_ready_providers.dart';

final dailyRhythmUiModelProvider = Provider<DailyRhythmUiModel?>((Ref ref) {
  final readyData = ref.watch(overviewReadyDataStateProvider);
  if (readyData == null) {
    return null;
  }

  final dashboard = readyData.dashboard;
  final now = dashboard.generatedAt;
  final hasEnvironment = dashboard.environmentSnapshot.noiseLabel != '等待采集';
  final hasScreen =
      !readyData.missingDimensions.any((item) => item.contains('屏幕'));

  return DailyRhythmUiModel(
    generatedAt: now,
    // 当前节点必须与本次 Dashboard 快照使用同一时间基准，避免刷新前后
    // 节点位置和卡片数据来自不同时间，造成节奏轴“跳点”。
    currentTime: now,
    hasRealData: dashboard.hasRealData,
    nodes: <DailyRhythmNode>[
      DailyRhythmNode(
        time: DateTime(now.year, now.month, now.day, 9),
        dimension: DailyRhythmDimension.activity,
        title: dashboard.stepCard.currentSteps >= 6000 ? '活动良好' : '活动积累中',
        value: '${dashboard.stepCard.currentSteps} 步',
        reason: '根据今天累计步数和目标完成度生成。',
        suggestion: dashboard.stepCard.currentSteps >= 6000
            ? '保持现在的活动节奏就很好。'
            : '找一个轻松的时段走动几分钟。',
        isAvailable: dashboard.hasRealData,
      ),
      DailyRhythmNode(
        time: DateTime(now.year, now.month, now.day, 14, 30),
        dimension: DailyRhythmDimension.posture,
        title: dashboard.sedentaryCard.totalMinutes >= 120 ? '久坐集中' : '姿势平稳',
        value: '久坐 ${_hours(dashboard.sedentaryCard.totalMinutes)} 小时',
        reason: '根据今天累计久坐和最长连续久坐片段生成。',
        suggestion: dashboard.sedentaryCard.totalMinutes >= 120
            ? '现在起身活动 3 分钟，先打断久坐。'
            : '继续保持每小时轻量活动。',
        isAvailable: dashboard.hasRealData,
      ),
      DailyRhythmNode(
        time: DateTime(now.year, now.month, now.day, 18),
        dimension: DailyRhythmDimension.noise,
        title: hasEnvironment
            ? '噪音${dashboard.environmentSnapshot.noiseLabel}'
            : '噪音数据不足',
        value: dashboard.environmentSnapshot.noiseLabel,
        reason: hasEnvironment ? '根据最近一次有效环境噪音摘要生成。' : '当前没有可用于判断的噪音样本。',
        suggestion: hasEnvironment ? '环境偏吵时，给自己一点安静空间。' : '开启麦克风权限后可补充环境判断。',
        isAvailable: hasEnvironment,
      ),
      DailyRhythmNode(
        time: DateTime(now.year, now.month, now.day, 21),
        dimension: DailyRhythmDimension.digital,
        title: hasScreen
            ? dashboard.screenCard.totalMinutes >= 180
                ? '看屏频繁'
                : '看屏适中'
            : '屏幕数据不足',
        value: '看屏 ${_hours(dashboard.screenCard.totalMinutes)} 小时',
        reason: hasScreen ? '根据今天的亮屏汇总生成。' : '当前平台尚未提供完整屏幕使用摘要。',
        suggestion: hasScreen ? '晚间给眼睛留一段无屏幕时间。' : '完成数字生活授权后可查看。',
        isAvailable: hasScreen,
      ),
    ],
  );
});

String _hours(int minutes) {
  final value = minutes / 60;
  return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
}
