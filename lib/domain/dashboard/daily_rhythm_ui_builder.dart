import 'package:health_monitor/domain/dashboard/daily_rhythm_concentration.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_signals.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_ui_model.dart';
import 'package:health_monitor/domain/dashboard/daily_rhythm_window.dart';
import 'package:health_monitor/domain/dashboard/dashboard_snapshot.dart';

/// 从仪表盘快照构建当日节奏轴 UI 模型，首页与简报共用同一套节点规则。
DailyRhythmUiModel? buildDailyRhythmUiModel({
  required DashboardSnapshot dashboard,
  required List<String> missingDimensions,
  required DateTime calendarDay,
  required DateTime windowEnd,
}) {
  var window = DailyRhythmWindow.forCalendarDay(
    calendarDay,
    windowEnd: windowEnd,
  );
  final signals = dashboard.rhythmSignals;
  final hasScreen =
      !missingDimensions.any((String item) => item.contains('屏幕'));

  final nodes = <DailyRhythmNode>[];
  if (DailyRhythmConcentration.shouldShowActivity(signals)) {
    final peakSteps = signals.activityPeakSteps;
    nodes.add(
      DailyRhythmNode(
        time: signals.activityPeakAt!,
        dimension: DailyRhythmDimension.activity,
        title: dashboard.stepCard.currentSteps >= dashboard.stepCard.goalSteps
            ? '活动良好'
            : '活动积累中',
        value: peakSteps != null && peakSteps > 0 ? '约 $peakSteps 步' : '活动集中',
        reason: _activityReason(signals),
        suggestion:
            dashboard.stepCard.currentSteps >= dashboard.stepCard.goalSteps
                ? '保持现在的活动节奏就很好。'
                : '找一个轻松的时段走动几分钟。',
        isAvailable: dashboard.hasRealData,
        showEventTime: signals.activityPeakIsPrecise,
      ),
    );
  }

  if (DailyRhythmConcentration.shouldShowStepGoalReached(
    signals,
    currentSteps: dashboard.stepCard.currentSteps,
    goalSteps: dashboard.stepCard.goalSteps,
  )) {
    nodes.add(
      DailyRhythmNode(
        time: signals.stepGoalReachedAt!,
        dimension: DailyRhythmDimension.activity,
        title: '步数达标',
        value: '${dashboard.stepCard.goalSteps} 步',
        reason: _stepGoalReason(signals, dashboard.stepCard),
        suggestion: '今天目标已完成，保持轻量活动即可。',
        isAvailable: dashboard.hasRealData,
        showEventTime: signals.stepGoalReachedIsPrecise,
      ),
    );
  }

  if (DailyRhythmConcentration.shouldShowPosture(signals)) {
    final longestMinutes = signals.sedentaryLongestMinutes ?? 0;
    nodes.add(
      DailyRhythmNode(
        time: signals.sedentaryStartAt!,
        dimension: DailyRhythmDimension.posture,
        title: dashboard.sedentaryCard.totalMinutes >= 60 ? '久坐偏多' : '久坐正常',
        value: '久坐 ${_nodeDurationLabel(longestMinutes)}',
        reason: _postureReason(signals),
        suggestion: dashboard.sedentaryCard.totalMinutes >= 60
            ? '现在起身活动 3 分钟，先打断久坐。'
            : '继续保持每小时轻量活动。',
        isAvailable: dashboard.hasRealData,
      ),
    );
  }

  if (DailyRhythmConcentration.shouldShowDigital(
    signals,
    hasScreen: hasScreen,
  )) {
    final sessionMinutes = signals.digitalLongestSessionMinutes ??
        dashboard.screenCard.longestSingleMinutes;
    nodes.add(
      DailyRhythmNode(
        time: signals.digitalUsageAt!,
        dimension: DailyRhythmDimension.digital,
        title: dashboard.screenCard.totalMinutes >= 120 ? '看屏频繁' : '看屏适中',
        value: '连续看屏 ${_nodeDurationLabel(sessionMinutes)}',
        reason: _digitalReason(
          signals,
          sessionMinutes: sessionMinutes,
        ),
        suggestion: '晚间给眼睛留一段无屏幕时间。',
        isAvailable: hasScreen,
      ),
    );
  }

  if (nodes.isEmpty) {
    return null;
  }

  nodes
      .sort((DailyRhythmNode a, DailyRhythmNode b) => a.time.compareTo(b.time));
  var visibleNodes = nodes
      .where((DailyRhythmNode node) => window.contains(node.time))
      .toList(growable: false);
  if (visibleNodes.isEmpty) {
    // 6:00 默认起点可能裁掉早间唯一节点，扩窗后仍只保留当日且不晚于现在的节点。
    final earliestNodeTime = nodes.first.time;
    if (earliestNodeTime.isBefore(window.start)) {
      window = DailyRhythmWindow(
        start: DateTime(
          earliestNodeTime.year,
          earliestNodeTime.month,
          earliestNodeTime.day,
          earliestNodeTime.hour,
        ),
        end: window.end,
      );
      visibleNodes = nodes
          .where((DailyRhythmNode node) => window.contains(node.time))
          .toList(growable: false);
    }
  }
  if (visibleNodes.isEmpty) {
    return null;
  }

  return DailyRhythmUiModel(
    generatedAt: dashboard.generatedAt,
    currentTime: windowEnd,
    windowStart: window.start,
    hasRealData: dashboard.hasRealData,
    nodes: visibleNodes,
  );
}

String _activityReason(DailyRhythmSignals signals) {
  final peakAt = signals.activityPeakAt;
  if (peakAt != null) {
    final peakSteps = signals.activityPeakSteps;
    if (!signals.activityPeakIsPrecise) {
      final stepHint = peakSteps != null && peakSteps > 0
          ? '今日已累计约 $peakSteps 步'
          : '今日步数已达标';
      return '$stepHint；当前缺少小时步数或增量样本，暂按当前节奏位置展示。';
    }
    final stepHint =
        peakSteps != null && peakSteps > 0 ? '约 $peakSteps 步' : '活动较集中';
    return '今天最活跃出现在 ${_time(peakAt)} 前后（$stepHint）。';
  }
  return '根据今天活动集中时段生成。';
}

String _stepGoalReason(DailyRhythmSignals signals, DashboardStepCard stepCard) {
  final reachedAt = signals.stepGoalReachedAt;
  if (reachedAt != null && signals.stepGoalReachedIsPrecise) {
    return '今天在 ${_time(reachedAt)} 左右达到 ${stepCard.goalSteps} 步目标。';
  }
  if (reachedAt != null) {
    return '今天已达到 ${stepCard.goalSteps} 步目标。';
  }
  return '根据今日步数目标完成度生成。';
}

String _postureReason(DailyRhythmSignals signals) {
  final startAt = signals.sedentaryStartAt;
  if (startAt != null) {
    final minutes = signals.sedentaryLongestMinutes;
    final durationHint =
        minutes != null && minutes > 0 ? '持续约 $minutes 分钟' : '持续时间较短';
    return '最长一段久坐从 ${_time(startAt)} 开始（$durationHint）。';
  }
  return '根据今天最长连续久坐片段生成。';
}

String _digitalReason(
  DailyRhythmSignals signals, {
  required int sessionMinutes,
}) {
  final usageAt = signals.digitalUsageAt;
  if (usageAt != null && signals.digitalUsageIsPrecise) {
    final durationHint =
        sessionMinutes > 0 ? '这一段连续使用约 $sessionMinutes 分钟' : '这一段连续使用偏短';
    return '从 ${_time(usageAt)} 开始，$durationHint。';
  }
  if (sessionMinutes > 0) {
    return '最长一段连续看屏约 $sessionMinutes 分钟。';
  }
  return '根据今天的看屏片段生成。';
}

String _nodeDurationLabel(int minutes) {
  if (minutes <= 0) {
    return '较短';
  }
  return '$minutes 分钟';
}

String _time(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
